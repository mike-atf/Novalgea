//
//  NewMedicineView.swift
//  Novalgea
//
//  Created by aDev on 12/02/2024.
//

import SwiftUI

struct NewMedicineView: View, Hashable {
    
    @Binding var medicine: Medicine
    @Binding var option: MedicineViewOption
    @Binding var path: NavigationPath
    @Binding var columnVisibility: NavigationSplitViewVisibility

    var body: some View {
        
        NewMedicineForm {
            Text(medicine.name)
            Text(medicine.startDate.formatted(date: .abbreviated, time: .shortened))
        }
        .onAppear {
            columnVisibility = .doubleColumn
        }
    }
    
    static func == (lhs: NewMedicineView, rhs: NewMedicineView) -> Bool {
        return lhs.medicine == rhs.medicine
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(medicine.uuid)
    }
    

}

#Preview {
    NewMedicineView(medicine: .constant(Medicine.preview), option: .constant(.name), path: .constant(NavigationPath()), columnVisibility: .constant(.doubleColumn))
}
