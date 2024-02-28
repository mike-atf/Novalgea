//
//  BackupManager.swift
//  Novalgea
//
//  Created by aDev on 22/02/2024.
//

import Foundation
import System
import AppleArchive
import SwiftData
import OSLog

@MainActor
class BackupManager {
    
    
    /// compressed the 3 .sqlite fiale sinside the ModelData folder into 1 archive file and returns it's url
    class func compressModelContainer() async throws -> URL? {
        
        let backupNumber = UserDefaults.standard.integer(forKey: Userdefaults.backupNumber.rawValue) + 1
        UserDefaults.standard.setValue(backupNumber, forKey: Userdefaults.backupNumber.rawValue)
        
        let fileName = "Novalgea Archive \(backupNumber).nba"
        
        let archiveLocation =  URL.applicationSupportDirectory.appending(path: fileName)
//        let archiveLocation =  URL.applicationSupportDirectory.appending(path: "NovalgeaData.nba")
        let archiveFilePath = FilePath(archiveLocation)!
        
        guard let writeFileStream = ArchiveByteStream.fileStream(path: archiveFilePath, mode: .writeOnly, options: [.create], permissions: FilePermissions(rawValue: 0o644)) else {
            throw InternalError(file: "BackupManager", function: "compressModelCantainer()", appError: "error compressing the .sqlite directory: writeFileStream failed")
        }
        
        defer {
            try? writeFileStream.close()
        }
        
        guard let compressStream = ArchiveByteStream.compressionStream(using: .lzfse, writingTo: writeFileStream) else {
            throw InternalError(file: "BackupManager", function: "compressModelCantainer()", appError: "error compressing the .sqlite directory: compressStream failed")
        }
        
        defer {
            try? compressStream.close()
        }
        
        guard let encodeStream = ArchiveStream.encodeStream(writingTo: compressStream) else {             
            throw InternalError(file: "BackupManager", function: "compressModelCantainer()", appError: "error compressing the .sqlite directory - encodeStream init failed")
        }
        
        defer {
            try? encodeStream.close()
        }
        
        guard let keySet = ArchiveHeader.FieldKeySet("TYP,PAT,LNK,DEV,DAT,UID,GID,MOD,FLG,MTM,BTM,CTM") else {
            throw InternalError(file: "BackupManager", function: "compressModelCantainer()", appError: "error compressing the .sqlite directory: keySet failed")
        }
        
        let sourcePath = URL.applicationSupportDirectory.appending(path: "ModelData")
        let source = FilePath(sourcePath)!
        
        do {
            try encodeStream.writeDirectoryContents(archiveFrom: source, keySet: keySet)
            // On return, directory.aar exists in NSTemporaryDirectory() and contains the compressed contents of src/.
            return archiveLocation
        } catch {
            throw InternalError(file: "BackupManager", function: "compressModelCantainer()", appError: "error compressing the .sqlite directory - encodeStream failed", osError: error.localizedDescription)
        }
        
    }
    
    class func decompressArchive(url: URL) async throws -> URL? {
        
        guard url.lastPathComponent.starts(with: "Novalgea") else {
            throw InternalError(file: "BackupManager", function: "decompressArchive()", appError: "import failed - incompatible archive \(url.lastPathComponent)")
        }
        
        guard let archiveFilePath = FilePath(url) else {
            throw InternalError(file: "BackupManager", function: "decompressArchive()", appError: "import failure - failure to get Filepath from archive url")
        }

        guard let readFileStream = ArchiveByteStream.fileStream(
                path: archiveFilePath,
                mode: .readOnly,
                options: [ ],
                permissions: FilePermissions(rawValue: 0o644)) else {
            throw InternalError(file: "BackupManager", function: "decompressArchive()", appError: "import failed - readFileStream failure")
        }
        defer {
            try? readFileStream.close()
        }
        
        guard let decompressStream = ArchiveByteStream.decompressionStream(readingFrom: readFileStream) else {
            throw InternalError(file: "BackupManager", function: "decompressArchive()", appError: "import failed - decompressStream failure")
        }
        
        defer {
            try? decompressStream.close()
        }
        
        guard let decodeStream = ArchiveStream.decodeStream(readingFrom: decompressStream) else {
            throw InternalError(file: "BackupManager", function: "decompressArchive()", appError: "import failed - decodeStream failure")
        }
        
        defer {
            try? decodeStream.close()
        }
        
        let decompressURL = URL.applicationSupportDirectory.appending(path:  "Import")
        let decompressPath = decompressURL.path
        
        if FileManager.default.fileExists(atPath: decompressPath) {
            
            try? FileManager.default.removeItem(at: decompressURL)
            
            do {
                try FileManager.default.createDirectory(atPath: decompressPath,
                                                        withIntermediateDirectories: true)
           } catch {
                throw InternalError(file: "BackupManager", function: "decompressArchive()", appError: "import failed - unable to create desstination directory", osError: error.localizedDescription)
            }
        } else {
            do {
                try FileManager.default.createDirectory(atPath: decompressPath,
                                                        withIntermediateDirectories: true)
           } catch {
                throw InternalError(file: "BackupManager", function: "decompressArchive()", appError: "import failed - unable to create desstination directory", osError: error.localizedDescription)
            }
        }

        let targetDestination = FilePath(decompressPath)
        
        guard let extractStream = ArchiveStream.extractStream(extractingTo: targetDestination,
                                                              flags: [ .ignoreOperationNotPermitted ]) else {
            throw InternalError(file: "BackupManager", function: "decompressArchive()", appError: "import failed - extractStream failure")
        }
        defer {
            try? extractStream.close()
        }
        
        do {
            _ = try ArchiveStream.process(readingFrom: decodeStream, writingTo: extractStream)

        } catch {
            throw InternalError(file: "BackupManager", function: "decompressArchive()", appError: "import failed - decodeStream process failure", osError: error.localizedDescription)
        }
        
        
        return decompressURL
    }
    
    class func setNewModelFolder(sourceURL: URL) async throws {
        
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            let ierror = InternalError(file: "BackupManager", function: "replaceModelFolder()", appError: "imported and decompressed folder not present at location 'Import")
            throw ierror
        }
        
        let sqliteFile = sourceURL.appending(path: "Novalgea.database.sqlite")
        guard FileManager.default.fileExists(atPath: sqliteFile.path) else {
            let ierror = InternalError(file: "BackupManager", function: "replaceModelFolder()", appError: "imported and decompressed folder 'Import' does not contain required file 'Novalgea.database.sqlite")
            throw ierror
        }
        
        let sqliteWALFile = sourceURL.appending(path: "Novalgea.database.sqlite-wal")
        guard FileManager.default.fileExists(atPath: sqliteWALFile.path) else {
            let ierror = InternalError(file: "BackupManager", function: "replaceModelFolder()", appError: "imported and decompressed folder 'Import' does not contain required file 'Novalgea.database.sqlite-wal")
            throw ierror
        }

        let sqliteSHMFile = sourceURL.appending(path: "Novalgea.database.sqlite-shm")
        guard FileManager.default.fileExists(atPath: sqliteSHMFile.path) else {
            let ierror = InternalError(file: "BackupManager", function: "replaceModelFolder()", appError: "imported and decompressed folder 'Import' does not contain required file 'Novalgea.database.sqlite-shm")
            throw ierror
        }
        
        try FileManager.default.removeItem(at: URL.applicationSupportDirectory.appending(path:  "ModelData"))
        
        try FileManager.default.moveItem(at: sourceURL, to: URL.applicationSupportDirectory.appending(path: "ModelData"))
        
    }
    
    /*
    class func importRecords(url: URL, container: ModelContainer) throws -> Set<Medicine> {
        
        Logger().info("Now starting to import archived records from \(url.lastPathComponent)...")
        let modelFolder = URL.applicationSupportDirectory.appending(path: "Import")
        
        let storeURL = modelFolder.appending(path: "Novalgea.database.sqlite")
        let config3 = ModelConfiguration(url: storeURL, cloudKitDatabase: .private("iCloud.co.uk.apptoolfactory.Novalgea"))
        
        let importContainer = try ModelContainer(for: Symptom.self, Medicine.self, DiaryEvent.self, ExerciseEvent.self, PRNMedEvent.self, Rating.self, InternalError.self, configurations: config3)
        
        let importContext = importContainer.mainContext
//        let appContext = container.mainContext
        var importedMedicines = Set<Medicine>()
        let fetchDescriptorM = FetchDescriptor<Medicine>(sortBy: [SortDescriptor(\.name)])
        if let existingMedicines = try? importContext.fetch(fetchDescriptorM)  {
            Logger().info("import container \(existingMedicines.count)")

            for medicine in existingMedicines {
                let new = Medicine(doses: medicine.doses.convertToDoses() ?? [Dose(unit: "mg", value1: 0.0)])
                new.copy(original: medicine)
//                appContext.insert(new)
                importedMedicines.insert(new)
                Logger().info("imported med \(new.name)")
            }
            
//            try appContext.save()
        }
        
//        let modelFolder2 = URL.applicationSupportDirectory.appending(path: "ModelData")
//        let storeURL2 = modelFolder.appending(path: "Novalgea.database.sqlite")
//        let config4 = ModelConfiguration(url: storeURL, cloudKitDatabase: .private("iCloud.co.uk.apptoolfactory.Novalgea"))
        
        Logger().info("Fetched \(importedMedicines.count) from archive for import")
        return importedMedicines

    }
    */
}
