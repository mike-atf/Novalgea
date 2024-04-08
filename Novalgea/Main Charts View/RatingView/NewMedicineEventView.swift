//
//  NewMedicineEventView.swift
//  Novalgea
//
//  Created by aDev on 04/04/2024.
//

import SwiftUI
import SwiftData

struct NewMedicineEventView: View {
    
    @Environment(\.modelContext) private var modelContext
 
    @Query(filter: #Predicate<Medicine> { medicine in
        medicine.isRegular == false &&
        medicine.currentStatus == "Current"
    }, sort: \Medicine.name, order: .reverse) var prnMedicines: [Medicine]

    @Binding var showView: Bool

    @State var selectedMedicine: Medicine?
    @State var selectedEventDate = Date.now

    var body: some View {
        if !prnMedicines.isEmpty {
            Form {
                Section {
                    Text(UserText.term("Medication event")).font(.title).bold()
                    
                    Picker(selection: $selectedMedicine) {
                        ForEach(prnMedicines) {
                            Text($0.name).tag($0 as Medicine?)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "pills.circle.fill").foregroundStyle(.orange).imageScale(.large)
                            Text("Select a Medicine").font(.title3).bold()
                        }
                    }
                    .pickerStyle(.inline)
                }
                
                Section {
                    BackdatingOptionView(selectedEventDate: $selectedEventDate)
                }
                
                Section {
                    Button {
                        addMedicineEvent()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(Font.title2.bold())
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }
                
                Section {
                    Button {
                        showView = false
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(Font.title2.bold())
                            .foregroundColor(.red)
                    }
                }
            }
        }
        else {
            VStack {
                ContentUnavailableView {
                    Label("", systemImage: "pills.circle.fill")
                } description: {
                    Text(UserText.term("No medicine yet"))
                }
                
                Button(UserText.term("Add a medicine")) {
                    //TODO: - create new medicine
                    print("new medicine")
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .presentationCompactAdaptation(.none)
            .padding()


        }

    }
    
    func addMedicineEvent() {
        
        guard selectedMedicine != nil else { return }

        let newMedEvent = MedicineEvent(endDate: selectedEventDate.addingTimeInterval(selectedMedicine!.effectDuration), startDate: selectedEventDate, medicine: selectedMedicine!)
        modelContext.insert(newMedEvent)
        saveContext()
        withAnimation {
            showView = false
        }
        selectedMedicine = nil
    }
    
    private func saveContext() {
        DispatchQueue.main.async {
            do {
                try modelContext.save()
            } catch {
                let ierror = InternalError(file: "NewMedicineEventView", function: "saveContext", appError: error.localizedDescription)
                ErrorManager.addError(error: ierror, container: modelContext.container)
            }
        }
    }


}

//#Preview {
//    NewMedicineEventView(_prnMedicines: [Medicine.preview], showView: Medicine.preview, selectedMedicine: Medicine.preview).modelContainer(DataController.previewContainer)
//}
