//
//  ABFImportDetail.swift
//  Novalgea
//
//  Created by aDev on 28/02/2024.
//

import SwiftUI
import SwiftData

struct ABFImportDetail: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.dismiss) private var dismiss

    var alogeaDocument: AlogeaBackupDocument?
    
    @State var showOptionsDialog = false
    @State var showProgressBar = false
    @State var showCompletion = false
    @State var importErrorMessage = ""
    
    var body: some View {
        
            List {
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "calendar.circle.fill").foregroundColor(.orange).imageScale(.large)
                            Text(UserText.term("Events") + ":").font(.title3)
                            Spacer()
                            Text((alogeaDocument?.events.count ?? 0).formatted())
                        }
                        if let newest = alogeaDocument?.events.first {
                            Divider()
                            HStack {
                                Text(UserText.term("Newest record"))
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
                            Image(systemName: "pills.circle.fill").foregroundColor(.teal).imageScale(.large)
                            Text(UserText.term("Drugs") + ":").font(.title3)
                            Spacer()
                            Text((alogeaDocument?.drugs.count ?? 0).formatted())
                        }
                        if let newest = alogeaDocument?.drugs.first {
                            Divider()
                            HStack {
                                Text(UserText.term("Newest drug"))
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
                            Image(systemName: "cross.circle.fill").foregroundColor(.red).imageScale(.large)
                            Text(UserText.term("Symptoms") + ":").font(.title3)
                            Spacer()
                            Text((alogeaDocument?.recordTypes.count ?? 0).formatted())
                        }
                        if let newest = alogeaDocument?.recordTypes.first {
                            Divider()
                            HStack {
                                Text(UserText.term("Newest symptom"))
                                Spacer()
                                Text(newest.dateCreated.formatted(date: .abbreviated, time: .omitted))
                            }.font(.footnote)
                            Text(newest.name).font(.footnote)
                        }
                    }
                }

                if (((alogeaDocument?.recordTypes.count ?? 0) + (alogeaDocument?.drugs.count ?? 0) + (alogeaDocument?.events.count ?? 0)) > 0 ) && !showProgressBar {
                    Section {
                        
                        Button {
                            showOptionsDialog = true
                        } label: {
                            Text(UserText.term("Import diary data"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(Font.title2.bold())
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.blue)
                    }
                    .confirmationDialog("Import options", isPresented: $showOptionsDialog) {
                        // attach to Section; when attached to Button or List won;t show properly on iPad; on ipad the 'Cancel' button is not shown - tap next to the dialog achieves the same
                        
                        Button(UserText.term("Add records to diary"), action: {
                            importRecords(replaceExisting: false)
                        })
                        
                        Button(UserText.term("Replace current diary"), role: .destructive, action: {
                            importRecords(replaceExisting: true)
                        })
                        
                        Button(UserText.term("Cancel"), role: .cancel, action: {
                            
                        })
                    }

                    Section {
                        Button {
                            dismiss()
                        } label: {
                            Text(UserText.term("Cancel"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(Font.title2.bold())
                                .foregroundColor(.gray)
                        }
                    }
                }
                if showProgressBar {
                    Section {
                        VStack(alignment: .center) {
                            Text(UserText.term("Importing, please wait...")).bold()
                            ProgressView()
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle(UserText.term("File contents"))
            .alert("Import process ended", isPresented: $showCompletion) {
                Button(UserText.term("Dimiss")) {
                    dismiss()
                }
            } message: {
                Text(importErrorMessage)
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
                    importErrorMessage = UserText.term("Success, no errors occurred")
                    showCompletion = true
                }
            } catch {
                let ierror = InternalError(file: "Alogea File ImportView", function: "importRecords", appError: "failure while trying to import Alogea archive records", osError: error.localizedDescription)
                await ErrorManager.addError(error: ierror, container: modelContext.container)
                DispatchQueue.main.async {
                    importErrorMessage = UserText.term("Import errors: ") + error.localizedDescription
                    showProgressBar = false
                    showCompletion = true
                }
            }
        }
   }

}

//#Preview {
//    ABFImportDetail()
//}
