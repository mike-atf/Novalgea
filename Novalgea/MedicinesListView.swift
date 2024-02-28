//
//  MedicinesListView.swift
//  Novalgea
//
//  Created by aDev on 08/02/2024.
//

import SwiftUI
import SwiftData

struct MedicinesListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Medicine.currentStatus, animation: .default)
    var medicines: [Medicine]
    
    @Query(filter: #Predicate<Medicine> { medicine in
        medicine.currentStatus == "Current"
    }, sort: \Medicine.startDate, order: .reverse) var currentMedicines: [Medicine]
    
    @Query(filter: #Predicate<Medicine> { medicine in
        medicine.currentStatus == "Discontinued"
    }, sort: \Medicine.startDate, order: .reverse) var endedMedicines: [Medicine]

    @Query(filter: #Predicate<Medicine> { medicine in
        medicine.currentStatus == "Planned"
    }, sort: \Medicine.startDate, order: .reverse) var plannedMedicines: [Medicine]


    
    /// without a sectioned Query available so far use 3 @Query arrsays
    /// 1. @query filtering current
    /// 2. @Query filtering ended
    /// 3. @Query filtering coming
    
    @State private var selection: Medicine?
    @State private var showAddMedicine = false

    
    var body: some View {
        NavigationSplitView {
            List {
                Section {
//                    if currentMedicines.count > 0 {
//                        Text("Current").font(.title).bold()
//                    }
                    ForEach(currentMedicines) { medicine in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(medicine.name)
                                Spacer()
                                Text(medicine.startDate.formatted())
                            }
                            Text(medicine.currentStatus).font(.footnote)
                        }
                    }
                } header: { 
                    if currentMedicines.count > 0 {
                        Text("Current")
                    }
                }
                .headerProminence(.increased)

                Section {
                    ForEach(plannedMedicines) { medicine in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(medicine.name)
                                Spacer()
                                Text(medicine.startDate.formatted())
                            }
                            Text(medicine.currentStatus).font(.footnote)
                        }
                    }
                } header: {
                    if plannedMedicines.count > 0 {
                        Text("Planned")
                    }
                }
                    .headerProminence(.increased)

                Section {
                    ForEach(endedMedicines) { medicine in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(medicine.name)
                                Spacer()
                                Text(medicine.startDate.formatted())
                            }
                            Text(medicine.currentStatus).font(.footnote)
                        }
                    }
                } header: { 
                    if endedMedicines.count > 0 {
                        Text("Discontinued")
                    }
                }
                .headerProminence(.increased)

            }
            .overlay {
                if medicines.isEmpty {
                    ContentUnavailableView {
                        Label("No Medicines", systemImage: "pills.circle.fill")
                    } description: {
                        Text("Medicines you create will appear here.")
                    }
                }
            }
            .toolbar {
                Spacer()
                Button {
//                    showAddMedicine = true
                    addMedicine()
                } label: {
                    Label("Add trip", systemImage: "plus")
                }
            }
        }
        detail: {
            if selection != nil {
                NavigationStack {
//                    NewMedicineView(medicine: selection!)
                }
            }
        }
        .onAppear {
            let fetchDescriptorM = FetchDescriptor<Medicine>(sortBy: [SortDescriptor(\Medicine.name)])
            let existingMedicines = try? modelContext.fetch(fetchDescriptorM)
            
            print("on appear there are \(existingMedicines?.count ?? 0 ) medicines in the context")
        }
    }
    
    private func addMedicine() {
        withAnimation {
            let newMedicine = Medicine(name: "Ami", doses: [Dose(unit: "mg", value1: 1000)])
            modelContext.insert(newMedicine)
//            selection = newMedicine
//            try! modelContext.save()
        }
    }
}

#Preview {
    MedicinesListView().modelContainer(DataController.previewContainer)
}
