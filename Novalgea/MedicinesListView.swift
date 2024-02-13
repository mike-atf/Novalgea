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
    
    /// without a sectioned Query available so far use 3 @Query arrsays
    /// 1. @query filtering current
    /// 2. @Query filtering ended
    /// 3. @Query filtering coming
    
    @State private var selection: Medicine?
    @State private var showAddMedicine = false

    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(medicines) { medicine in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(medicine.name)
                            Spacer()
                            Text(medicine.startDate.formatted())
                        }
                        Text(medicine.currentStatus).font(.footnote)
                    }
                }
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
                    showAddMedicine = true
                } label: {
                    Label("Add trip", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showAddMedicine) {
                NavigationStack {
                    NewMedicineView()
                }
                .presentationDetents([.medium, .large])
            }

        }
        detail: {
            if let selection = selection {
                NavigationStack {

                }
            }
        }
    }
    
    @MainActor private func addMedicine() {
        let newMedicine =  Medicine(dose: Dose(unit: "mg", value1: 0))
        modelContext.insert(newMedicine)
    }
}

#Preview {
    MedicinesListView().modelContainer(DataController.previewContainer)
}
