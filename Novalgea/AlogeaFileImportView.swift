//
//  AlogeaFileImportView.swift
//  Novalgea
//
//  Created by aDev on 14/02/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import OSLog

// how NavSplitView works: has a 'Parent' NSV, an optional 'content' SideBar/List view and a 'detail' view.
// an optional @State object of interest from the Parent view is selected in the List/SideBar view
// and shared as @Binding (for editing) or simple variable (for viewing only) with the content and or detail view
// selection within a NavigationLink in the SideBar view adds to the NavigationPath, which triggers a navigation
// Content and Detail view are embedded in a NavigationStack (with optional (path: $path)), and the SideBAr contains a NavigationLink as selection tool that adds the selected object to the navigationPath, which is a @State object of the Parent view.
// The back button, or removal of object from the navigationPath triggers a navigation backwards.
struct AlogeaFileImportView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State var alogeaDocument: AlogeaBackupDocument?
    @State var path = NavigationPath()

    var body: some View {
        
        NavigationSplitView {
                ABFImportList(path: $path, alogeaDocument: $alogeaDocument)
        } detail: {
            NavigationStack {
            }
        }
    }
    
    
}

//#Preview {
//    AlogeaFileImportView(path: [AlogeaBackupDocument()])
//}
