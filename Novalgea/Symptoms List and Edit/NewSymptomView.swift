//
//  NewSymptomView.swift
//  Novalgea
//
//  Created by aDev on 26/03/2024.
//

import SwiftUI
import SwiftData
import OSLog

struct NewSymptomView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \Symptom.name) var symptomsList: [Symptom]
    @Query(sort: \Medicine.name) var medicinesList: [Medicine]
    
    @Binding var selectedSymptom: Symptom?
  
    @FocusState private var focused: Bool

    @State var type = SymptomType.symptom
    @State var name = UserText.term("")
    @State var nonunique = String()
    @State var maxVAS: Double = 10.0
    @State var showAlert = false
    @State var alertMessage = String()
    @State var selectedColor = Color(UIColor(named: "s0")!)
    @State var availableColors = ColorScheme.symptomColorsArray
    @State var selectedMedicines = Set<Medicine>()
    @State var treatingMedicines = Set<Medicine>()
    
    var createNew: Bool

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
                    let header = createNew ? UserText.term("New ") : UserText.term("Edit ")
                    Image(systemName: "bolt.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.orange)
                    Text(header + UserText.term(type.rawValue)).font(.title).bold()
                }
                TextField(UserText.term("Name"), text: $name)
                    .focused($focused)
                    .onSubmit {
                        //TODO: - check extension requried
                        
                        if symptomsList.compactMap({ $0.name }).contains(name) {
                            nonunique = name
                            name = String()
                            alertMessage = UserText.term("\(nonunique) as \(type.rawValue) already exists. Please pick another.")
                            showAlert = true
                        }
                    }
                
            }
            
            Section {
                ColorSelectionPicker(selectedColor: $selectedColor, colorPalette: ColorScheme.symptomColorsArray, image: Image(systemName: "paintpalette.fill"), imageColor: Color.orange)
                    .padding(.bottom)
            }
            
            Section {
                HStack {
                    let text = type == .sideEffect ? UserText.term("Triggering medicines") : UserText.term("Treating medicine(s)")
                    
                    Image(systemName: "pills.circle.fill")
                    .imageScale(.large)
                    .foregroundColor(.orange)
                    Text(text).font(.title3).bold()
                }
                
                MultiSelectionPicker_M(selectedMedicines: $selectedMedicines, medicinesChoices: Set(medicinesList))
                .foregroundStyle(.primary)

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
                    .listRowBackground((name == "" && selectedMedicines.count == 0) ? Color.gray: Color.blue)
                    .disabled((name == "" && selectedMedicines.count == 0))
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
        .navigationTitle(createNew ? UserText.term("Add a symptom") : UserText.term("Edit a symptom"))
        .onAppear {
            focused = true
            setTemporaryValues() //crashes preview
       }
        .alert(UserText.term("Can't save this"), isPresented: $showAlert) {
        } message: {
            Text(alertMessage)
        }
        .onChange(of: selectedSymptom) { oldValue, newValue in
            // required as otherwise (on iPad) changing the list view selection -> selectedSymptom does not update Texts and Pickers as selectedSymptom is not used directly in these
            setTemporaryValues() //crashes preview
        }
    }
    
    private func setTemporaryValues() {
        
        name = selectedSymptom?.name ?? ""
        availableColors = getAvailableColors()
        
        if !createNew { // edit existing symptom
            if let selectedSymptom {
                selectedColor = selectedSymptom.color()
                if selectedSymptom.type == SymptomType.symptom.rawValue {
                    type = SymptomType.symptom
                    for med in selectedSymptom.treatingMeds ?? [] {
                        treatingMedicines.insert(med)
                    }

                }
                else {
                    type = SymptomType.sideEffect
                    for med in selectedSymptom.causingMeds ?? [] {
                        treatingMedicines.insert(med)
                    }

                }
            }
        } else {
            selectedColor = availableColors.first ?? ColorScheme.symptomColorsArray.randomElement()!
        }
    }
    
    private func getAvailableColors() -> [Color] {
        // can't use this in 'onAppear' with @MainActor ColorManager  - error 'Cannot assign value of type '@MainActor (ModelContainer) -> [Color]' to type '[Color]'
        
        var available = [Color]()

        let usedColorsArray = symptomsList.compactMap { $0.color() }
        
        var usedColors = Set<Color>()
        for color in usedColorsArray {
            usedColors.insert(color)
        }
        for eColor in ColorScheme.symptomColorsArray {
            if !usedColors.contains(eColor) {
                available.append(eColor)
            }
        }
        return available.count == 0 ? ColorScheme.symptomColorsArray : available
    }
    
    private func save() {
        
        if createNew { // new
            var newSymptom: Symptom
            if type == .sideEffect {
                newSymptom = Symptom(name: name, type: type.rawValue, creatingDevice: UIDevice.current.name, maxVAS: 10.0, causingMeds: Array(treatingMedicines), color: selectedColor)
            } else {
                newSymptom = Symptom(name: name, type: type.rawValue, creatingDevice: UIDevice.current.name, maxVAS: 10.0, treatingMeds: Array(treatingMedicines), color: selectedColor)
            }
            modelContext.insert(newSymptom)
            selectedSymptom = newSymptom
            UserDefaults.standard.setValue(newSymptom.uuid.uuidString, forKey: Userdefaults.lastSelectedSymptom.rawValue)
        } else { // edit
            selectedSymptom?.name = name
            selectedSymptom?.setNewColor(color: selectedColor)
            selectedSymptom?.type = type.rawValue
            if type == .symptom {
                selectedSymptom?.treatingMeds = Array(selectedMedicines)
                selectedSymptom?.causingMeds = [Medicine]()
            } else {
                selectedSymptom?.treatingMeds = [Medicine]()
                selectedSymptom?.causingMeds = Array(selectedMedicines)
            }
            UserDefaults.standard.setValue(selectedSymptom?.uuid.uuidString, forKey: Userdefaults.lastSelectedSymptom.rawValue)
        }
        saveContext()

        selectedSymptom = nil // triggers backward navigation
        dismiss()
    }
    
    private func cancel() {
        selectedSymptom = nil // triggers backward navigation
        dismiss()
    }
    
    private func saveContext() {
        DispatchQueue.main.async {
            do {
                try modelContext.save()
            } catch {
                let ierror = InternalError(file: "NewSymptomView", function: "saveContext", appError: error.localizedDescription)
                ErrorManager.addError(error: ierror, container: modelContext.container)
            }
        }
    }


}

#Preview {
    NewSymptomView(selectedSymptom: .constant(Symptom.preview), createNew: true).modelContainer(DataController.previewContainer)
}
