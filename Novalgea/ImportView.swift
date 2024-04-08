//
//  ImportView.swift
//  Novalgea
//
//  Created by aDev on 24/02/2024.
//

import SwiftUI
import OSLog
import SwiftData
import UniformTypeIdentifiers

struct ImportView: View {
    
    @Binding var modelContainer: ModelContainer
    
    @State var showImport = false
    @State var showImportAlert = false
    @State var alertMessage = String()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Image(systemName: "arrow.down.doc.fill").foregroundColor(.blue).imageScale(.large)
                Text("Import a Novalgea Diary Archive").font(.title)
                Text("This will replace your existing diary.").font(.title2)
                Text("It's recommended to make a local Backup before proceeding")
            }
            .fileImporter(isPresented: $showImport, allowedContentTypes: [UTType(filenameExtension: "nba")!, .novalgeaBackupArchive]) { result in
                switch result {
                case .success(let file):
                    // gain access to the directory
                    let gotAccess = file.startAccessingSecurityScopedResource()
                    if !gotAccess { return }
                    // access the directory URL
                    // (read templates in the directory, make a bookmark, etc.)
                    decompressArchive(fileURL: file)
                    // release access
                    file.stopAccessingSecurityScopedResource()
                case .failure(let error):
                    // handle error
                    print(error)
                }
            }
            .onAppear {
                Logger().info("Document directory at \(URL.applicationSupportDirectory)")
            }
            .alert("Import process ended", isPresented: $showImportAlert) {
                
            } message: {
                Text(alertMessage)
            }
            .toolbar{
                
                Button {
                    showImport = true
                } label: {
                    Image(systemName: "square.and.arrow.down.fill").foregroundColor(.blue)
                    Text("Import Archive")
                }

            }
        }
        .navigationTitle("Export Diary Archive")
    }
    
    @MainActor private func decompressArchive(fileURL: URL) {
        
        do {
            try modelContainer.mainContext.delete(model: DiaryEvent.self)
            try modelContainer.mainContext.delete(model: ExerciseEvent.self)
            try modelContainer.mainContext.delete(model: Medicine.self)
            try modelContainer.mainContext.delete(model: MedicineEvent.self)
            try modelContainer.mainContext.delete(model: Rating.self)
            try modelContainer.mainContext.delete(model: Symptom.self)
            
            try modelContainer.mainContext.save()
        } catch {
                if let ie = error as? InternalError {
                    DispatchQueue.main.async {
                        ErrorManager.addError(error: ie, container: modelContainer)
                    }
                }
                alertMessage = error.localizedDescription
                showImportAlert = true
            }

        Task {
            do {
                if  let url = try await BackupManager.decompressArchive(url: fileURL) {
                    
                    try await BackupManager.setNewModelFolder(sourceURL: url)
                    
                    let storeURL = URL.applicationSupportDirectory.appending(path: "ModelData").appending(path: "Novalgea.database.sqlite")
                    let config = ModelConfiguration(url: storeURL, cloudKitDatabase: .private("iCloud.co.uk.apptoolfactory.Novalgea"))
                    modelContainer = try ModelContainer(for: Symptom.self, Medicine.self, DiaryEvent.self, ExerciseEvent.self, MedicineEvent.self, Rating.self, InternalError.self, EventCategory.self, configurations: config)

                    alertMessage = "Import of archive successful"
                    showImportAlert = true
                }
            } catch {
                if let ie = error as? InternalError {
                    DispatchQueue.main.async {
                        ErrorManager.addError(error: ie, container: modelContainer)
                    }
                }
                alertMessage = error.localizedDescription
                showImportAlert = true
            }
        }
    }
        
}

//#Preview {
//    ImportView(modelContainer: ModelContainerPreview().container)
//}
