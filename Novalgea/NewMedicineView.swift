//
//  NewMedicineView.swift
//  Novalgea
//
//  Created by aDev on 12/02/2024.
//

import SwiftUI

struct NewMedicineView: View {
    
    var medicine: Medicine
    
    var body: some View {
        NewMedicineForm {
            Text(medicine.name)
            Text(medicine.startDate.formatted(date: .abbreviated, time: .shortened))
        }
    }
}

#Preview {
    NewMedicineView(medicine: (Medicine.preview))
}
