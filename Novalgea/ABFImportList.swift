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

    @State var showProgressBar = false
    @State var importFile = false
    @State var showProceed = false
    @State var showOptionsDialog = false
    @State var showCompletion = false
    @State var importErrorMessage = ""

    var body: some View {
        List {
            if alogeaDocument != nil {
                Section {
//                    NavigationLink(value: alogeaDocument) {
//                        Text("\(importFileName ?? UserText.term( "none"))")
//                    }
                    NavigationLink("\(alogeaDocument?.fileName ?? UserText.term( "none"))") {
                        ABFImportDetail(alogeaDocument: alogeaDocument)
                    }
                    if showProgressBar {
                        Divider()
                        HStack {
                            //TODO: - add cancel function here
                            Text(UserText.term( "Importing - this may take a moment...")).font(.footnote)
                            Spacer()
                            ProgressView()
                        }
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
                            Text("Select a file for import").bold()
                        }.buttonStyle(.borderedProminent)
                    }
                } description: {
                    Text("Must be an Alogea Backup file of type .abf")
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
//        .toolbar {
//            Button("Select Diary file") {
//                importFile = true
//            }
//        }
        .confirmationDialog("Import options", isPresented: $showOptionsDialog) {
            
            Button("Add records to diary", action: {
                showProgressBar = true
                importRecords(replaceExisting: false)
            })
            
            Button("Replace current diary", role: .destructive, action: {
                showProgressBar = true
                importRecords(replaceExisting: true)
            })
            
            Button("Cancel import", role: .cancel, action: {
                
            })
            
        }
        .alert(UserText.term( "Import complete"), isPresented: $showCompletion) {
            Button("Dismiss") {
                
            }
        } message: {
            Text(importErrorMessage)
        }

    }
    
    @MainActor private func readAlogeaFile(fileURL: URL) {
        
        alogeaDocument = AlogeaBackupDocument(fileURL: fileURL)

        guard alogeaDocument != nil else {
            let error = InternalError(file: "ABF_FileView", function: ".readAlogeaFile()", appError: "document file remains nil")
            ErrorManager.addError(error: error, container: modelContext.container)
            importErrorMessage = "Import failed: the import document could not be initialized"
            showCompletion = true
            return
        }
        alogeaDocument?.fileName = fileURL.lastPathComponent
        path.append(alogeaDocument)
        
        Task {
            guard await alogeaDocument!.open() else {
                let error = InternalError(file: "ABF_FileView", function: ".onAppear()", appError: "failed to open UIDocument")
                ErrorManager.addError(error: error, container: modelContext.container)
                importErrorMessage = "Import failed: the import document could not be opened"
                showCompletion = true
                return
            }
            await alogeaDocument!.extractDataFromFile(container: modelContext.container)
        }

    }
    
    private func importRecords(replaceExisting: Bool) {
        
        showProgressBar = true
        
        Task {
            
            if replaceExisting {
                 // TODO: - make a safety backup here
                try modelContext.delete(model: DiaryEvent.self)
                try modelContext.delete(model: ExerciseEvent.self)
                try modelContext.delete(model: Medicine.self)
                try modelContext.delete(model: PRNMedEvent.self)
                try modelContext.delete(model: Rating.self)
                try modelContext.delete(model: Symptom.self)
            }

            do {
                try await alogeaDocument?.importAlogeaRecords(container: modelContext.container)
                DispatchQueue.main.async {
                    showProgressBar = false
                    showCompletion = true
                }
            } catch {
                let ierror = InternalError(file: "Alogea File ImportView", function: "importRecords", appError: "failure while trying to import Alogea archive records", osError: error.localizedDescription)
                await ErrorManager.addError(error: ierror, container: modelContext.container)
                DispatchQueue.main.async {
                    importErrorMessage = UserText.term( "Import errors: \(error.localizedDescription)")
                    showProgressBar = false
                    showCompletion = true
                }
            }
        }
   }

}

//#Preview {
//    ABFImportList(importFileName: <#Binding<String?>#>, path: <#Binding<[AlogeaBackupDocument]?>#>)
//}
