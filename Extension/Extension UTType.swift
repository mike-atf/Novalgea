//
//  Extension UTType.swift
//  Novalgea
//
//  Created by aDev on 28/02/2024.
//

import Foundation
import UniformTypeIdentifiers

extension UTType {
    static var alogeaBackupDocument: UTType {
        UTType(importedAs: "co.uk.apptoolfactory.alogea.document.abf")
    }
    
    static var novalgeaBackupArchive: UTType {
        UTType(importedAs: "co.uk.apptoolfactory.novalgea.archive.nba")
    }
}
