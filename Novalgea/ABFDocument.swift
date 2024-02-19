//
//  ABFDocument.swift
//  Novalgea
//
//  Created by aDev on 14/02/2024.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var alogeaBackupDocument: UTType {
        UTType(importedAs: "co.uk.apptoolfactory.alogea.document.abf")
    }
}


struct ABFDocument: FileDocument {
    
    static var readableContentTypes = [UTType.alogeaBackupDocument]
    
    var content = Data()
    
    init(data: Data) {
        self.content = data
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.content = data
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = content
        return FileWrapper(regularFileWithContents: data)
    }
    

}
