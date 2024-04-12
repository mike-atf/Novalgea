//
//  NewSymptomView.swift
//  Novalgea
//
//  Created by aDev on 26/03/2024.
//

import SwiftUI
import SwiftData

struct NewSymptomView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Symptom.name) var symptomsList: [Symptom]
    @Query(sort: \Medicine.name) var medicinesList: [Medicine]
    
    @Binding var showView: Bool
    @Binding var selectedSymptom: Symptom?
  
    @FocusState private var focused: Bool

    @State var type = SymptomType.symptom
    @State var name = UserText.term("")
    @State var nonunique = String()
    @State var maxVAS: Double = 10.0
    @State var showAlert = false
    @State var alertMessage = String()
//    @State var saveDisabled = true
    @State var selectedMedicine: Medicine?
    @State var treatingMedicines = Set<Medicine>()

    var body: some View {
        
        Form {
            
            if !medicinesList.isEmpty {
                Section {
                    Picker(UserText.term("Type"), selection: $type) {
                        
                        ForEach(SymptomType.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            
            Section {
                HStack {
                    Image(systemName: "bolt.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.orange)
                    Text(UserText.term("New ") + UserText.term(type.rawValue)).font(.title).bold()
                }
                TextField(UserText.term("Name"), text: $name)
                    .focused($focused)
                    .onSubmit {
                        //TODO: - check extension requried
                        
                        if symptomsList.compactMap({ $0.name }).contains(name) {
                            nonunique = name
                            name = String()
                            alertMessage = UserText.term("\(nonunique) as \(type.rawValue) already exists. Consider chosing another.")
                            showAlert = true
                        }
                    }
                
            }
            
//            Section {
//                VStack(alignment: .leading) {
//                    Text(UserText.term("Maximum score ")).font(.title).bold()
//                    Text(UserText.term("Must be 10.0 or higher"))
//                }
//               TextField("Top Score number", value: $maxVAS, format: .number)
//                    .onSubmit {
//                        if maxVAS < 10 {
//                            maxVAS = 10
//                            alertMessage = UserText.term("Max score must be 10.0 or greater")
//                            showAlert = true
//                        }
//                   }
//            }
            
            if type == .sideEffect {
                Section {
                    HStack {
                        Image(systemName: "pills.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.orange)
                        Text(UserText.term("Triggering medicine")).font(.title).bold()
                    }
                    Picker("Select one", selection: $selectedMedicine) {
                        List {
                            ForEach(medicinesList) { med in
                                Text(med.name)
                            }
                        }
                    }
                }
            }
            else {
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "pills.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.orange)
                            Text(UserText.term("Treating medicine(s)")).font(.title).bold()
                        }
                        Text(UserText.term("Optional but recommended")).font(.footnote)
                    }
                    List {
                        ForEach(medicinesList) { med in
                            Button {
                                if treatingMedicines.contains(med) {
                                    treatingMedicines.remove(med)
                                } else {
                                    treatingMedicines.insert(med)
                                }
                            } label: {
                                HStack {
                                    if (treatingMedicines.count == 0) {
                                        Image(systemName: "circle")
                                    } else if treatingMedicines.contains(med) {
                                        Image(systemName: "checkmark.circle.fill").symbolRenderingMode(.multicolor)
                                    } else {
                                        Image(systemName: "circle")
                                    }
                                    Text(med.name).font(.footnote)
                                }
                            }
                        }
                    }
                    .foregroundStyle(.primary)
                }
            }
            
            Section {
                if type == .symptom {
                    Button {
                        save()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(Font.title2.bold())
                            .foregroundColor(.white)
                    }
                    .listRowBackground(name == "" ? Color.gray: Color.blue)
                    .disabled(name == "")
                }
                else {
                    Button {
                        save()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(Font.title2.bold())
                            .foregroundColor(.white)
                    }
                    .listRowBackground((name == "" && selectedMedicine == nil) ? Color.gray: Color.blue)
                    .disabled((name == "" && selectedMedicine == nil))
                }
            }
            
            Section {
                Button {
                    cancel()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(Font.title2.bold())
                        .foregroundColor(.red)
                }
            }
            
        }
        .onAppear {
            focused = true
        }
        .navigationTitle(UserText.term("Add a symptom to track"))
        .alert(UserText.term("Can't save this"), isPresented: $showAlert) {
            
        } message: {
            Text(alertMessage)
        }
        
    }
    
    private func save() {
        
        var newSymptom: Symptom
        
        if type == .sideEffect {
            newSymptom = Symptom(name: name, type: type.rawValue, creatingDevice: UIDevice.current.name, maxVAS: 10.0, causingMeds: [selectedMedicine!])
        } else {
            newSymptom = Symptom(name: name, type: type.rawValue, creatingDevice: UIDevice.current.name, maxVAS: 10.0, treatingMeds: Array(treatingMedicines))

        }
        modelContext.insert(newSymptom)
        selectedSymptom = newSymptom
        showView = false
    }
    
    private func cancel() {
        showView = false
    }

}

#Preview {
    NewSymptomView(showView: .constant(true), selectedSymptom: .constant(Symptom.preview)).modelContainer(DataController.previewContainer)
}
