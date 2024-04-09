//
//  SymptomListPickerView.swift
//  Novalgea
//
//  Created by aDev on 08/04/2024.
//

import SwiftUI
import SwiftData
import OSLog

struct SymptomListPickerView: View {
    
    @Environment(\.modelContext) private var modelContext
//    @Query(sort: \Symptom.name) var symptoms: [Symptom]

    @Binding var selectedSymptom: Symptom?
    @Binding var showSymptomEntry: Bool
    
    var symptoms: [Symptom]
    
    init(symptoms:[Symptom] ,selectedSymptom: Binding<Symptom?>, showSymptomEntry: Binding<Bool>) {
        _selectedSymptom = selectedSymptom
        _showSymptomEntry = showSymptomEntry
        self.symptoms = symptoms
        
        if symptoms.count > 0 { // if 0 then the nicer 'Add new' VStack is shown
            self.symptoms.append(Symptom(name: "Add new", type: "Symptom"))
        }
    }

    var body: some View {
        
        if !symptoms.isEmpty {
            Picker(selection: $selectedSymptom) {
                ForEach(symptoms, id: \.self) { symptom in
                    Text(symptom.name).tag(symptom as Symptom?)
                }
            } label: {
                HStack {
                    Image(systemName: "bolt.circle.fill").imageScale(.large).foregroundStyle(.orange)
                    Text(UserText.term("Select symptom or side effect")).bold()
                }
            }
            .onAppear(perform: {
                if symptoms.count == 1 {
                    selectedSymptom = symptoms.first!
                }
            })
            .pickerStyle(.inline)
            .onChange(of: selectedSymptom) { oldValue, newValue in
                if selectedSymptom?.name == "Add new" {
                    showSymptomEntry = true
                    selectedSymptom = symptoms.first
                }
            }
        } else {
            VStack {
                ContentUnavailableView {
                    Label("", systemImage: "bolt.circle.fill")
                } description: {
                    Text(UserText.term("No symptom yet"))
                }

                Button(UserText.term("Add one")) {
                    showSymptomEntry = true
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .padding()
        }
    }
}

#Preview {
    SymptomListPickerView(symptoms: [Symptom.preview], selectedSymptom: .constant(Symptom.preview), showSymptomEntry: .constant(false)).modelContainer(DataController.previewContainer)
}
