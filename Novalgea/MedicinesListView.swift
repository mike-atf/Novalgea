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
    var nonOptionalSelection: Binding<Medicine> {
        Binding(
            get: { selection ?? Medicine.placeholder },
            set: { selection = $0 }
        )
    }

    @State private var medicineViewOption: MedicineViewOption? = nil
    
    @State private var showAddMedicine = false
    @State var path = NavigationPath()
    
    @State private var columnVisibility =
        NavigationSplitViewVisibility.all
    
    var body: some View {
        
        NavigationSplitView(columnVisibility: $columnVisibility) {
            
                List(currentMedicines, selection: $selection) { currentmed in
                    
                    NavigationLink(value: currentmed) {
                        HStack {
                            Circle()
                                .fill(currentmed.color()).frame(height: 20)
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(currentmed.name).font(.title3.bold())
                                    Spacer()
                                    Text(currentmed.dosesDescription())
                                }
                                HStack {
                                    Text(UserText.term("Started "))
                                    Text(currentmed.startDate.formatted(date: .abbreviated, time: .omitted))
                                }
                            }
                        }
                    }
                    .swipeActions {
                        Button(UserText.term("Delete"), role: .destructive) {
                            deleteMedicine(medToDelete: currentmed)
                        }
                    }
                }
                .overlay {
                    if medicines.isEmpty {
                        ContentUnavailableView {
                            Label(UserText.term("No Medicines"), systemImage: "pills.circle.fill")
                        } description: {
                            Text(UserText.term("Medicines you create will appear here"))
                        }
                    }
                }
                .toolbar {
                    Spacer()
                    Button {
                        addMedicine()
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
                .navigationTitle(UserText.term("Medicines list"))
        }
        content: {
            NavigationStack {
                if selection != nil {
                    MedicinesContentView(viewOption: $medicineViewOption, path: $path, medicineName: selection!.name)
                }
                else {
                    ContentUnavailableView {
                        Label(UserText.term("Select a medcine"), systemImage: "square.and.pencil.circle")
                    } description: {
                        Text(UserText.term("View and edit option will be listed here"))
                    }

                }
            }
            
        }
        detail: {
            NavigationStack(path: $path) {
                if selection != nil && medicineViewOption != nil {
                    switch medicineViewOption {
                    case .alerts:
                        NewMedicineView(medicine: Binding (
                            get: { selection ?? Medicine.placeholder },
                            set: { selection = $0 }
                        ), option: Binding (
                            get: { medicineViewOption ?? .name },
                            set: { medicineViewOption = $0 }
                        ), path: $path, columnVisibility: $columnVisibility)
                    case .name:
                        NewMedicineView(medicine: Binding (
                            get: { selection ?? Medicine.placeholder },
                            set: { selection = $0 }
                        ), option: Binding (
                            get: { medicineViewOption ?? .name },
                            set: { medicineViewOption = $0 }
                        ), path: $path, columnVisibility: $columnVisibility)
                    case .doses:
                        NewMedicineView(medicine: Binding (
                            get: { selection ?? Medicine.placeholder },
                            set: { selection = $0 }
                        ), option: Binding (
                            get: { medicineViewOption ?? .name },
                            set: { medicineViewOption = $0 }
                        ), path: $path, columnVisibility: $columnVisibility)
                   case .titration:
                        NewMedicineView(medicine: Binding (
                            get: { selection ?? Medicine.placeholder },
                            set: { selection = $0 }
                        ), option: Binding (
                            get: { medicineViewOption ?? .name },
                            set: { medicineViewOption = $0 }
                        ), path: $path, columnVisibility: $columnVisibility)
                    case nil:
                        ContentUnavailableView {
                            Label("Select an option", systemImage: "filemenu.and.cursorarrow")
                        } description: {
                            Text("Options will appear here")
                        }
                    }
                }
            }
        }
    }
    
    private func addMedicine() {
        saveContext()
        
        let newMedicine = Medicine.new
        withAnimation {
             modelContext.insert(newMedicine)
        }
        medicineViewOption = .name
        selection = newMedicine
    }
    
    private func deleteMedicine(medToDelete: Medicine) {
        withAnimation {
            modelContext.delete(medToDelete)
        }
        saveContext()
    }
    
    private func saveContext() {
        DispatchQueue.main.async {
            do {
                try modelContext.save()
            } catch {
                let ierror = InternalError(file: "MedicinesListView", function: "saveContext", appError: error.localizedDescription)
                ErrorManager.addError(error: ierror, container: modelContext.container)
            }
        }
    }

}

#Preview {
    MedicinesListView().modelContainer(DataController.previewContainer)
}
