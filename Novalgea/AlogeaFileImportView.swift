//
//  AlogeaFileImportView.swift
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


struct AlogeaFileImportView: View, ImportDelegate {
    
    @Environment(\.modelContext) private var modelContext
    
    @State var importFile = false
    @State var importFileName: String?
    @State var alogeaDocument: AlogeaBackupDocument?
    
    @State var events: [Alogea_Event]?
    @State var drugs: [Alogea_Drug]?
    @State var recordTypes: [Alogea_RecordType]?
    
    @State var showProceed = false
    @State var showOptionsDialog = false
    @State var showProgressBar = false
    @State var progress = 0.0


    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("\(importFileName ?? "")")
                }
                Section {
                    HStack {
                        Text("events:")
                        Spacer()
                        Text((events?.count ?? 0).formatted())
                    }
                    HStack {
                        Text("drugs:")
                        Spacer()
                        Text((drugs?.count ?? 0).formatted())
                    }
                    HStack {
                        Text("symptoms:")
                        Spacer()
                        Text((recordTypes?.count ?? 0).formatted())
                    }
                }
                if (((recordTypes?.count ?? 0) + (drugs?.count ?? 0) + (events?.count ?? 0)) > 0 ) {
                    Section {
                        
                        Button {
                            showOptionsDialog = true
                        } label: {
                            Text("Import diary data")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(Font.title2.bold())
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.blue)

                        
                    }
                    .confirmationDialog("Import options", isPresented: $showOptionsDialog) {
                        // attach to Section; when attached to Button or List won;t show properly on iPad; on ipad the 'Cancel' button is not shown - tap next to the dialog achieves the same
                        
                        Button("Add records to diary", action: {
                            importRecords(replaceExisting: false)
                        })
                        
                        Button("Replace current diary", role: .destructive, action: {
                            importRecords(replaceExisting: true)
                        })
                        
                        Button("Cancel import", role: .cancel, action: {
                            
                        })

                    }
                }
                if showProgressBar {
                    Section {
                        ProgressView(NSLocalizedString("Preparing new backup", comment: ""), value: progress, total: 1.0)
                    }
                }
            }
            .padding()

            .fileImporter(isPresented: $importFile, allowedContentTypes: [.alogeaBackupDocument]) { result in
                switch result {
                case .success(let importURL):
                    importFileName = importURL.lastPathComponent
                    readAlogeaFile(fileURL: importURL)
                case .failure(let error):
                    let intError = InternalError(file: "ABFFileViewer", function: "fileImporter()", appError: "error importing file", osError: error.localizedDescription)
                    ErrorManager.addError(error: intError, container: modelContext.container)
                }
            }
            .toolbar {
                Button("Open Diary file") {
                    importFile = true
                }
            }
            .confirmationDialog("Import options", isPresented: $showOptionsDialog) {
                
                Button("Add records to diary", action: {
                    showProgressBar = true
                    progress = 0.0
                    importRecords(replaceExisting: false)
                })
                
                Button("Replace current diary", role: .destructive, action: {
                    showProgressBar = true
                    progress = 0.0
                    importRecords(replaceExisting: true)
                })
                
                Button("Cancel import", role: .cancel, action: {
                    
                })

            }
        }
    }
    
    @MainActor private func readAlogeaFile(fileURL: URL) {
        
        alogeaDocument = AlogeaBackupDocument(fileURL: fileURL)

        guard alogeaDocument != nil else {
            let error = InternalError(file: "ABF_FileView", function: ".readAlogeaFile()", appError: "document file remains nil")
            ErrorManager.addError(error: error, container: modelContext.container)
            return
        }
        
        Task {
            guard await alogeaDocument!.open() else {
                let error = InternalError(file: "ABF_FileView", function: ".onAppear()", appError: "failed to open UIDocument")
                ErrorManager.addError(error: error, container: modelContext.container)
                return
            }
            await alogeaDocument?.extractDataFromFile(container: modelContext.container)
            
            events = alogeaDocument?.events
            drugs = alogeaDocument?.drugs
            recordTypes = alogeaDocument?.recordTypes
        }

    }
    
    private func importRecords(replaceExisting: Bool) {
        
        Task {
            do {
                try await alogeaDocument?.importAlogeaRecords(replaceCurrentRecords: replaceExisting, container: modelContext.container, delegate: self)
                DispatchQueue.main.async {
                    progress = 1.0
                    showProgressBar = false
                }
            } catch {
                let ierror = InternalError(file: "Alogea File ImportView", function: "importRecords", appError: "failure while trying to import Alogea archive records", osError: error.localizedDescription)
                await ErrorManager.addError(error: ierror, container: modelContext.container)
                DispatchQueue.main.async {
                    progress = 1.0
                    showProgressBar = false
                }
            }
        }
   }
    
    func progressUpdate(progress: Double) {
        self.progress = progress
        print("progress updated to \(progress)")
    }
}

#Preview {
    AlogeaFileImportView()
}
