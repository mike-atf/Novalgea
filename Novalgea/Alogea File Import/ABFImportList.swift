//
//  ABFImportList.swift
//  Novalgea
//
//  Created by aDev on 28/02/2024.
//

import SwiftUI

struct ABFImportList: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Binding var path: NavigationPath //[AlogeaBackupDocument]
    @Binding var alogeaDocument: AlogeaBackupDocument?

    @State var importFile = false
    @State var showProceed = false
    @State var showOptionsDialog = false
    @State var showCompletion = false
    @State var importErrorMessage = ""

    var body: some View {
        List {
            if alogeaDocument != nil {
                Section {
                    NavigationLink("\(alogeaDocument?.fileName ?? UserText.term( "none"))") {
                        ABFImportDetail(alogeaDocument: alogeaDocument)
                    }
                }
            }
        }
        .navigationDestination(item: $alogeaDocument, destination: { item in
            ABFImportDetail(alogeaDocument: item)
        })
        .overlay {
            if alogeaDocument == nil {
                ContentUnavailableView {
                    VStack {
                        Image(systemName: "doc.circle.fill").imageScale(.large).foregroundColor(.gray).padding(.bottom)
                        Button {
                            importFile = true
                        } label: {
                            Text(UserText.term("Select a file for import")).bold()
                        }.buttonStyle(.borderedProminent)
                    }
                } description: {
                    Text(UserText.term("This must be an Alogea Backup file of type '.abf'"))
                        .padding(.top)
                }
            }
        }
        .fileImporter(isPresented: $importFile, allowedContentTypes: [.alogeaBackupDocument]) { result in
            switch result {
            case .success(let importURL):
                readAlogeaFile(fileURL: importURL)
            case .failure(let error):
                let intError = InternalError(file: "ABFFileViewer", function: "fileImporter()", appError: "error importing file", osError: error.localizedDescription)
                ErrorManager.addError(error: intError, container: modelContext.container)
                importErrorMessage = "Import failed: \(error.localizedDescription)"
                showCompletion = true
            }
        }

    }
    
    private func readAlogeaFile(fileURL: URL) {
        
        alogeaDocument = AlogeaBackupDocument(fileURL: fileURL)

        guard alogeaDocument != nil else {
            let error = InternalError(file: "ABF_FileView", function: ".readAlogeaFile()", appError: "document file remains nil")
            DispatchQueue.main.async {
                ErrorManager.addError(error: error, container: modelContext.container)
            }
            importErrorMessage = "Import failed: the import document could not be initialized"
            showCompletion = true
            return
        }
        alogeaDocument?.fileName = fileURL.lastPathComponent
        path.append(alogeaDocument) // on finishing import file in 'ABFImportDetail' is set to nil which result in navigation back to root
        
        Task {
            guard await alogeaDocument!.open() else {
                let error = InternalError(file: "ABF_FileView", function: ".onAppear()", appError: "failed to open UIDocument")
                DispatchQueue.main.async {
                    ErrorManager.addError(error: error, container: modelContext.container)
                }
                importErrorMessage = "Import failed: the import document could not be opened"
                showCompletion = true
                return
            }
            await alogeaDocument!.extractDataFromFile(container: modelContext.container)
        }

    }

}

//#Preview {
//    ABFImportList(importFileName: <#Binding<String?>#>, path: <#Binding<[AlogeaBackupDocument]?>#>)
//}
