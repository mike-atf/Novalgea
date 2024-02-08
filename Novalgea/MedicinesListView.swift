//
//  MedicinesListView.swift
//  Novalgea
//
//  Created by aDev on 08/02/2024.
//

import SwiftUI
import SwiftData

struct MedicinesListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query
    var medicines: [Medicine]
    
    var body: some View {
        List {
            ForEach(medicines) { medicine in
                VStack {
                    HStack {
                        Text(medicine.name)
                        Text(medicine.startDate.formatted())
                    }
                    Text(medicine.currentStatus)
                }
            }
        }
    }
}

#Preview {
    MedicinesListView().modelContainer(Medicine.preview)
}
