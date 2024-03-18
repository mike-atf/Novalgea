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
    
    @Query(filter: #Predicate<Symptom> { symptom in
        symptom.type == "Symptom"
    }, sort: \Symptom.name) var symptoms: [Symptom]

    @Query(filter: #Predicate<Symptom> { symptom in
        symptom.type == "Side effect"
    }, sort: \Symptom.name) var sideEffects: [Symptom]

    /// without a sectioned Query available so far use 3 @Query arrsays
    /// 1. @query filtering current
    /// 2. @Query filtering ended
    /// 3. @Query filtering coming
    
    @State private var selection: Symptom?
    @State private var showAddSymptom = false

    
    var body: some View {
        NavigationSplitView {
            List {
                Section {
                    ForEach(symptoms) { symptom in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(symptom.name)
                                Spacer()
                                Text(symptom.type)
                            }
                            Text(symptom.maxVAS.formatted()).font(.footnote)
                        }
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                deleteSymptom(symptomToDelete: symptom)
                            }
                        }

                    }
                    
                } header: {
                    if symptoms.count > 0 {
                        Text("Symptoms")
                    }
                }
                .headerProminence(.increased)

                Section {
                    ForEach(sideEffects) { symptom in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(symptom.name)
                                Spacer()
                                Text(symptom.type)
                            }
                            Text(symptom.maxVAS.formatted()).font(.footnote)
                        }
                        .swipeActions {
                            Button("Delete", role: .destructive) {
                                deleteSymptom(symptomToDelete: symptom)
                            }
                        }

                    }
                    
                } header: {
                    if symptoms.count > 0 {
                        Text("Side effects")
                    }
                }
                .headerProminence(.increased)

            }
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
                    addSymptom()
                } label: {
                    Label("Add Symptom", systemImage: "plus")
                }
            }
        }
        detail: {
            if selection != nil {
                NavigationStack {

                }
            }
        }
        .onAppear {
            let fetchDescriptorM = FetchDescriptor<Symptom>(sortBy: [SortDescriptor(\Symptom.name)])
            let existingSymptoms = try? modelContext.fetch(fetchDescriptorM)
            
            print("on appear there are \(existingSymptoms?.count ?? 0 ) symptoms in the context")
        }
    }
    
    private func addSymptom() {
        withAnimation {
            let newSymptom = Symptom(name: "new Symptom", type: "Symptom", creatingDevice: UIDevice.current.name)
            modelContext.insert(newSymptom)
            saveContext()
        }
    }
    
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
