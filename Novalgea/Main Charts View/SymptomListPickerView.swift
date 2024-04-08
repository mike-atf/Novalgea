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
    @Query(sort: \Symptom.name) var symptoms: [Symptom]

    @Binding var selectedSymptom: Symptom?
    @Binding var showSymptomEntry: Bool

    var body: some View {
        
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
        .overlay {
            if symptoms.isEmpty {
                VStack {
                    ContentUnavailableView {
                        Label("", systemImage: "pills.circle.fill")
                    } description: {
                        Text(UserText.term("No symptom yet"))
                    }
                    
                    Button(UserText.term("Add one")) {
                        showSymptomEntry = true
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
                .presentationCompactAdaptation(.none)
                .padding()
            }
        }
    }
}

#Preview {
    SymptomListPickerView(selectedSymptom: .constant(Symptom.preview), showSymptomEntry: .constant(false)).modelContainer(DataController.previewContainer)
}
