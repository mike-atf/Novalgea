//
//  ExportArchive.swift
//  Novalgea
//
//  Created by aDev on 23/02/2024.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ExportArchive: FileDocument {
    static var readableContentTypes: [UTType] = [.novalgeaArchive]
    
    var content: Data
    
    ini
}

extension UTType {
    static var novalgeaArchive = UTType(exportedAs: "co.uk.novalgea.archive")
}
