//
//  ListPopoverButton_M.swift
//  Novalgea
//
//  Created by aDev on 17/03/2024.
//

import SwiftUI

struct ListPopoverButton_M: View {
    
    @Binding var showMedicinesList: Bool
    @Binding var selectedMedicines: Set<Medicine>?
    
    var medicines: [Medicine]
    var iconPosition: Position = .trailing
    
    var body: some View {
        Button {
            showMedicinesList = true
        } label: {
            HStack {
                if iconPosition == .leading {
                    Image(systemName: "eye.circle.fill").imageScale(.medium)
                }

                if selectedMedicines?.count ?? 0 > 0 {
                    Text(UserText.term("Meds: ") + "\(selectedMedicines!.count)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                } else {
                    Text(UserText.term("Meds: ") + UserText.term("All"))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                if iconPosition == .trailing {
                    Image(systemName: "eye.circle.fill").imageScale(.medium)
                }
            }
        }
        .popover(isPresented: $showMedicinesList) {
            
            if medicines.count == 0 {
                VStack {
                    ContentUnavailableView {
                        Label("", systemImage: "pills.circle.fill")
                    } description: {
                        Text(UserText.term("No medicine yet"))
                    }
                    
                    Button(UserText.term("Add one")) {
                        print("new medicine")
                    }
                    .buttonStyle(BorderedButtonStyle())
                }
                .presentationCompactAdaptation(.none)
                .padding()
            } else {
                VStack(alignment: .leading) {
                    ForEach(medicines) { m0 in
                        Button {
                            if selectedMedicines == nil {
                                selectedMedicines = Set<Medicine>()
                                selectedMedicines!.insert(m0)
                            }
                            else if selectedMedicines!.contains(m0) {
                                selectedMedicines!.remove(m0)
                            } else {
                                selectedMedicines!.insert(m0)
                            }
                        } label: {
                            HStack {
                                if (selectedMedicines == nil) {
                                    Image(systemName: "circle")
                                } else if selectedMedicines!.contains(m0) {
                                    Image(systemName: "checkmark.circle.fill").symbolRenderingMode(.multicolor)
                                } else {
                                    Image(systemName: "circle")
                                }
                                Text(m0.name).font(.footnote)
                            }
                        }
                        Divider()
                        
                    }
                }
                .presentationCompactAdaptation(.none)
                .padding() // popover VStack padding
            }
        }

    }
}

#Preview {
    ListPopoverButton_M(showMedicinesList: .constant(false), selectedMedicines: .constant(Set(_immutableCocoaSet: Medicine.preview)), medicines: [Medicine.preview])
}
