//
//  ListPopoverButton.swift
//  Novalgea
//
//  Created by aDev on 17/03/2024.
//

import SwiftUI

struct ListPopoverButton: View {
    
    @Binding var showSymptomList: Bool
    @Binding var showNewSymptomView: Bool
    @Binding var selectedSymptoms: Set<Symptom>?
    
    var symptoms: [Symptom]
    
    var body: some View {
        
        Button {
            showSymptomList = true
        } label: {
            HStack {
                Image(systemName: "eye.circle.fill").imageScale(.medium)
                if selectedSymptoms?.count ?? 0 > 0 {
                    Text(UserText.term("Symptoms: ") + "\(selectedSymptoms!.count)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                } else {
                    Text(UserText.term("Symptoms: ") + UserText.term("All"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .popover(isPresented: $showSymptomList) {

                if symptoms.count == 0 {
                    VStack {
                        ContentUnavailableView {
                            Label("", systemImage: "bolt.circle.fill")
                        } description: {
                            Text(UserText.term("No symptoms yet"))
                        }
                        
                        Button(UserText.term("Add one")) {
                            showSymptomList = false
                            showNewSymptomView = true
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                    .presentationCompactAdaptation(.none)
                    .padding() // popover VStack padding
            } else {
                VStack(alignment: .leading) {

                    ForEach(symptoms) { s0 in
                        Button {
                            if selectedSymptoms == nil {
                                selectedSymptoms = Set<Symptom>()
                                selectedSymptoms!.insert(s0)
                            }
                            else if selectedSymptoms!.contains(s0) {
                                selectedSymptoms!.remove(s0)
                            } else {
                                selectedSymptoms!.insert(s0)
                            }
                        } label: {
                            HStack {
                                if (selectedSymptoms == nil) {
                                    Image(systemName: "circle")
                                } else if selectedSymptoms!.contains(s0) {
                                    Image(systemName: "checkmark.circle.fill").symbolRenderingMode(.multicolor)
                                } else {
                                    Image(systemName: "circle")
                                }
                                Text(s0.name).font(.footnote)
                            }
                            
                        }
                        Divider()
                        
                    }
                    Divider()
                    Button(UserText.term("Add symptom")) {
                        showSymptomList = false
                        showNewSymptomView = true
                    }
                    .buttonStyle(BorderedButtonStyle())

                }
                .presentationCompactAdaptation(.none)
                .padding() // popover VStack padding
            }

        }


    }
}

//#Preview {
//    ListPopoverButton()
//}
