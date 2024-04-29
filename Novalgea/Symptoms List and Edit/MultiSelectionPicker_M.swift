//
//  MultiSelectionPicker_M.swift
//  Novalgea
//
//  Created by aDev on 27/04/2024.
//

import SwiftUI
import OSLog

struct MultiSelectionPicker_M: View {
    
    @Binding var selectedMedicines: Set<Medicine>
    var medicinesChoices: Set<Medicine>
    
    var body: some View {
        List {
            ForEach(Array(medicinesChoices)) { medOption in
                Button {
                    if selectedMedicines.contains(medOption) {
                        selectedMedicines.remove(medOption)
                    } else {
                        selectedMedicines.insert(medOption)
                    }
                } label: {
                    HStack {
                        if selectedMedicines.contains(medOption) {
                            Image(systemName: "checkmark.circle.fill")
                            .symbolRenderingMode(.multicolor)
                        } else {
                            Image(systemName: "circle")
                        }
                        Text(medOption.name)
                        Spacer()
                        Circle()
                            .fill(medOption.color())
                            .frame(height: 20)
                    }
                }
            }
        }
    }
}

#Preview {
    MultiSelectionPicker_M(selectedMedicines: .constant(Set(_immutableCocoaSet: Medicine.preview)), medicinesChoices: [Medicine.preview])
}
