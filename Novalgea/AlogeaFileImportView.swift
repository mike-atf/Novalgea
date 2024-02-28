//
//  AlogeaFileImportView.swift
//  Novalgea
//
//  Created by aDev on 14/02/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import OSLog


struct AlogeaFileImportView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @State var importFile = false
    @State var importFileName: String?
    @State var alogeaDocument: AlogeaBackupDocument?
    
    @State var showProceed = false
    @State var showOptionsDialog = false
    @State var showProgressBar = false
    @State var showCompletion = false
    
    @State var importErrorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "doc.fill")
                                Text(UserText.term(e: "Selected file")).font(.title3)
                            }
                            Text("\(importFileName ?? UserText.term(e: "none"))")
                            if showProgressBar {
                                Divider()
                                HStack {
                                    //TODO: - add cancel function here
                                    Text(UserText.term(e: "Importing - this may take a moment...")).font(.footnote)
                                    Spacer()
                                    ProgressView()
                                }
                            }
                        }
                    }
                    Section {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "calendar")
                                Text(UserText.term(e: "Events") + ":").font(.title3)
                                Spacer()
                                Text((alogeaDocument?.events.count ?? 0).formatted())
                            }
                            if let newest = alogeaDocument?.events.first {
                                Divider()
                                HStack {
                                    Text(UserText.term(e: "Newest record"))
                                    Spacer()
                                    Text(newest.date.formatted(date: .abbreviated, time: .shortened))
                                }.font(.footnote)
                                HStack {
                                    Text(newest.name)
                                    Spacer()
                                    Text(newest.note ?? "")
                                }.font(.footnote)
                            }
                        }
                    }
                    Section {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "pills.fill")
                                Text(UserText.term(e: "Drugs") + ":").font(.title3)
                                Spacer()
                                Text((alogeaDocument?.drugs.count ?? 0).formatted())
                            }
                            if let newest = alogeaDocument?.drugs.first {
                                Divider()
                                HStack {
                                    Text(UserText.term(e: "Newest drug"))
                                    Spacer()
                                    Text(newest.startDate.formatted(date: .abbreviated, time: .omitted))
                                }.font(.footnote)
                                HStack {
                                    Text(newest.name)
                                    Spacer()
                                    Text(newest.dosesText())
                                }.font(.footnote)
                            }
                        }
                    }
                    Section {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "cross.fill")
                                Text(UserText.term(e: "Symptoms") + ":").font(.title3)
                                Spacer()
                                Text((alogeaDocument?.recordTypes.count ?? 0).formatted())
                            }
                            if let newest = alogeaDocument?.recordTypes.first {
                                Divider()
                                HStack {
                                    Text(UserText.term(e: "Newest symptom"))
                                    Spacer()
                                    Text(newest.dateCreated.formatted(date: .abbreviated, time: .omitted))
                                }.font(.footnote)
                                Text(newest.name).font(.footnote)
                            }
                        }
                    }
                    //                }
                    if (((alogeaDocument?.recordTypes.count ?? 0) + (alogeaDocument?.drugs.count ?? 0) + (alogeaDocument?.events.count ?? 0)) > 0 ) {
                        Section {
                            
                            if !showProgressBar {
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
                        importRecords(replaceExisting: false)
                    })
                    
                    Button("Replace current diary", role: .destructive, action: {
                        showProgressBar = true
                        importRecords(replaceExisting: true)
                    })
                    
                    Button("Cancel import", role: .cancel, action: {
                        
                    })
                    
                }
                .alert(UserText.term(e: "Import complete"), isPresented: $showCompletion) {
                    Button("Dismiss") {
                        
                    }
                } message: {
                    Text(importErrorMessage)
                }

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
                    importErrorMessage = UserText.term(e: "Import errors: \(error.localizedDescription)")
                    showProgressBar = false
                    showCompletion = true
                }
            }
        }
   }
    
}

#Preview {
    AlogeaFileImportView()
}
