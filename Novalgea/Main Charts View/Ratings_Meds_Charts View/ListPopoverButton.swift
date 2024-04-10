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
    @Binding var selectedSideEffects: Set<Symptom>?

    var symptoms: [Symptom]
    var sideEffects: [Symptom]

    var body: some View {
        
        // Label of the button in surrounding UI
        Button {
            showSymptomList = true
        } label: {
            HStack {
                Image(systemName: "eye.circle.fill").imageScale(.medium)
                if selectedSymptoms?.count ?? 0 > 0 {
                    Text(UserText.term("Symptoms: show ") + "\(selectedSymptoms!.count)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                } else {
                    Text(UserText.term("Symptoms: ") + UserText.term("Show all"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .popover(isPresented: $showSymptomList) {
            // View revealed when button clicked
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
                    
                    Text(UserText.term("Show only...")).font(.callout).bold()
                    Divider()

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
                            .foregroundColor(.primary)
                        }
                        Divider()
                        
                    }
                    
                    if selectedSymptoms?.count ?? 0 > 0 {
                        Button(UserText.term("Show all")) {
                            selectedSymptoms = nil
                            showSymptomList = false
                        }
                        .buttonStyle(BorderedButtonStyle())
                        Divider()
                    }
                    
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
