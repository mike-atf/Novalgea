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
    
    @Query(sort: \InternalError.maxDate, order: .reverse, animation: .default)
    var errors: [InternalError]
        
    @State var selection: InternalError?
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    @State var errorToDelete: InternalError?

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
                    .swipeActions {
                        
                        Button(action: {
                            errorToDelete = error
                            deleteError()
                        }, label: {
                            Image(systemName: "trash")
                        })
                        .tint(.red)
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
                    deleteAllErrors()
                } label: {
                    Label("Delete all", systemImage: "trash.fill")
                }
//                Spacer()
//                Button {
//                    addError()
//                } label: {
//                    Label("Errors", systemImage: "plus")
//                }
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
    
    private func deleteError() {
        
        guard let deleteError = errorToDelete else { return }
        
        withAnimation {
            modelContext.delete(deleteError)
            errorToDelete = nil
        }
    }
    
    @MainActor private func deleteAllErrors() {
        do {
            try modelContext.delete(model: InternalError.self)
        } catch {
            let ierror = InternalError(file: "ErrorsListView", function: "deleteAllErrors()", appError: "error trying to delete all stored errors", osError: error.localizedDescription)
            ErrorManager.addError(error: ierror, container: modelContext.container)
        }
    }
}

#Preview {
    ErrorsListView().modelContainer(DataController.previewContainer)
}
