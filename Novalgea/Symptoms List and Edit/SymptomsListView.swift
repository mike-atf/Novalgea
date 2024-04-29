//
//  SymptomsListView.swift
//  Novalgea
//
//  Created by aDev on 17/03/2024.
//

import SwiftUI
import SwiftData

struct SymptomsListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query var symptoms: [Symptom]

//    @Query(filter: #Predicate<Symptom> { symptom in
//        symptom.type == "Side effect"
//    }, sort: \Symptom.name) var sideEffects: [Symptom]

    /// without a sectioned Query available so far use 3 @Query arrsays
    /// 1. @query filtering current
    /// 2. @Query filtering ended
    /// 3. @Query filtering coming
    
    @State private var selection: Symptom?
    @State private var showAddSymptom = false
    @State private var path = NavigationPath()

    
    var body: some View {
        
        NavigationSplitView {
                        
            List(symptoms, selection: $selection) { symptom in
                
                let typeText = symptom.isSideEffect ? UserText.term("Side effect") : UserText.term("Symptom")
                let meds = symptom.isSideEffect ? symptom.causingMeds?.compactMap { $0.name}  : symptom.treatingMeds?.compactMap { $0.name}
                let medsText = meds?.combinedString() ?? "-"
                NavigationLink(value: symptom) {
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Circle()
                                .fill(symptom.color())
                                .frame(height: 20)
                            Text(symptom.name).bold()
                            Spacer()
                            Text((symptom.ratingEvents?.count ?? 0).formatted())
                        }
                        Text(typeText)
                        HStack {
                            Text(UserText.term("Medicines: "))
                            Text(medsText)
                        }
                    }
                }
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        deleteSymptom(symptomToDelete: symptom)
                    }
                }
            }
            .navigationDestination(item: $selection, destination: { _ in
                NewSymptomView(selectedSymptom: $selection, createNew: false) // edit
            })
            .navigationTitle(UserText.term("Symptoms & Side effects"))
            .overlay {
                if symptoms.isEmpty {
                    ContentUnavailableView {
                        Label("No Symptoms", systemImage: "bolt.circle")
                    } description: {
                        Text("Symptoms you create will appear here.")
                    }
                }
            }
            .toolbar {
                Spacer()
                Button {
                    showAddSymptom = true
                } label: {
                    Label("Add Symptom", systemImage: "plus")
                }
            }
        }
        detail: {
            if selection != nil {
                NavigationStack {
                    NewSymptomView(selectedSymptom: $selection, createNew: false)
                }
            }
        }
        .sheet(isPresented: $showAddSymptom, content: {
            NewSymptomView(selectedSymptom: $selection, createNew: false)
        })
    }
    
//    private func addSymptom() {
//        withAnimation {
//            let newSymptom = Symptom(name: "new Symptom", type: "Symptom", creatingDevice: UIDevice.current.name)
//            modelContext.insert(newSymptom)
//            saveContext()
//        }
//    }
    
    private func deleteSymptom(symptomToDelete: Symptom) {
        modelContext.delete(symptomToDelete)
        saveContext()
    }
    
    private func saveContext() {
        DispatchQueue.main.async {
            do {
                try modelContext.save()
            } catch {
                let ierror = InternalError(file: "SymptomListView", function: "saveContext", appError: error.localizedDescription)
                ErrorManager.addError(error: ierror, container: modelContext.container)
            }
        }
    }

    
    
}

#Preview {
    SymptomsListView().modelContainer(DataController.previewContainer)
}
