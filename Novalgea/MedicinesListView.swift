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
                VStack(alignment: .leading) {
                    HStack {
                        Text(medicine.name)
                        Spacer()
                        Text(medicine.startDate.formatted())
                    }
                    Text(medicine.currentStatus).font(.footnote)
                }
            }
        }
    }
}

#Preview {
    MedicinesListView().modelContainer(DataController.previewContainer)
}
