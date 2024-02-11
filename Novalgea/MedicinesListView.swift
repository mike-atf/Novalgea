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
    
    @State private var selection: Medicine?

    
    var body: some View {
        NavigationSplitView {
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
            .overlay {
                if medicines.isEmpty {
                    ContentUnavailableView {
                        Label("No Medicines", systemImage: "pills.circle.fill")
                    } description: {
                        Text("Medicines you create will appear here.")
                    }
                }
            }
            .toolbar {
                Button {
                    addError()
                } label: {
                    Label("Errors", systemImage: "ladybug.circle")
                }
            }
        }
        detail: {
            if let selection = selection {
                NavigationStack {

                }
            }
        }
    }
    
    @MainActor private func addError() {
        let newError =  InternalError(file: "MedicinesListView", function: "addError", appError: "addd test error")
        ErrorManager.addError(error: newError, container: modelContext.container)
    }
}

#Preview {
    MedicinesListView().modelContainer(DataController.previewContainer)
}
