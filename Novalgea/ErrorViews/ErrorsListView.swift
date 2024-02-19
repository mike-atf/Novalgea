//
//  ErrorsListView.swift
//  Novalgea
//
//  Created by aDev on 08/02/2024.
//

import SwiftUI
import SwiftData

struct ErrorsListView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query
    var errors: [InternalError]
        
    @State var selection: InternalError?
    @State private var columnVisibility = NavigationSplitViewVisibility.all

    var body: some View {
        
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(errors, selection: $selection) { error in

                    NavigationLink(value: error) {
                        HStack {
                            Text(error.appError)
                            Spacer()
                            Text(error.count.formatted(.number))
                        }
                    }
            }
            .navigationTitle("Error List")
            .overlay {
                if errors.isEmpty {
                    ContentUnavailableView {
                        Label("No Errors", systemImage: "ant.circle")
                    } description: {
                        Text("Internal errors will be listed here.")
                    }
                }
            }
            .toolbar {
                Button {
                    addError()
                } label: {
                    Label("Errors", systemImage: "plus")
                }
            }
        } content: {
            NavigationStack {
                if let selectedError = selection {
                    let binding = Binding { selectedError } set: { selection = $0 }
                    
                    ErrorDetailView(error: binding)
                }
            }
        }
        detail: {
            if let selectedError = selection {
                NavigationStack {
                    ErrorDatesView(dates: selectedError.dates)
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    @MainActor private func addError() {
        let newError =  InternalError(file: "ErrorsListView", function: "addError", appError: "added test error \(Int.random(in: 1...10))")
        ErrorManager.addError(error: newError, container: modelContext.container)
    }
}

#Preview {
    ErrorsListView().modelContainer(DataController.previewContainer)
}
