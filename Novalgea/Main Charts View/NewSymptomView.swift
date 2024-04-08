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
    @FocusState private var focused: Bool

    @State var type = SymptomType.symptom
    @State var name = UserText.term("")
    @State var nonunique = String()
    @State var maxVAS: Double = 10.0
    @State var showAlert = false
    @State var alertMessage = String()
    @State var saveDisabled = true
    @State var selectedMedicine: Medicine?

    var body: some View {
        
        Form {
            
            if !medicinesList.isEmpty {
                Section {
                    Picker("Show", selection: $type) {
                        
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
                    Text(UserText.term("Name of new ") + UserText.term(type.rawValue)).font(.title).bold()
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
                        } else if maxVAS >= 10.0 && name != "" {
                            saveDisabled = false
                        }
                    }
                
            }
            
            Section {
                VStack(alignment: .leading) {
                    Text(UserText.term("Maximum score ")).font(.title).bold()
                    Text(UserText.term("Must be 10.0 or higher"))
                }
               TextField("Top Score number", value: $maxVAS, format: .number)
                    .onSubmit {
                        if maxVAS < 10 {
                            maxVAS = 10
                            alertMessage = UserText.term("Max score must be 10.0 or greater")
                            showAlert = true
                        }
                   }
            }
            
            if type == .sideEffect {
                Section {
                    HStack {
                        Image(systemName: "pills.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.orange)
                        Text(UserText.term("Select related medicine")).font(.title).bold()
                    }
                    Picker("Select medicine", selection: $selectedMedicine) {
                        List {
                            ForEach(medicinesList) { med in
                                Text(med.name)
                            }
                        }
                    }
                }
            }
            
            Section {
                
                    Button {
                        save()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(Font.title2.bold())
                            .foregroundColor(.white)
                    }
                    .listRowBackground(saveDisabled ? Color.gray: Color.blue)
                    .disabled(saveDisabled)
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
        
        let new = Symptom(name: name, type: type.rawValue, creatingDevice: UIDevice.current.name, maxVAS: maxVAS)
        modelContext.insert(new)
        showView = false
    }
    
    private func cancel() {
        showView = false
    }

}

#Preview {
    NewSymptomView(showView: .constant(true)).modelContainer(DataController.previewContainer)
}
