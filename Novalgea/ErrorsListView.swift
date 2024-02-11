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
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(errors) { error in

                    NavigationLink(value: error) {
                        HStack {
                            Text(error.appError)
                            Spacer()
                            Text(error.count.formatted(.number))
                        }
                    }
                }
                .navigationDestination(for: InternalError.self) { error in
                    ErrorDetailView(error: error)
                }
            }.toolbar {
                Button {
                    addError()
                } label: {
                    Label("Errors", systemImage: "ladybug.circle")
                }
            }
        } detail: {
            if let selection = selection {
                NavigationStack {
                    ErrorDetailView(error: selection)
                }
            }
        }
    
    }
    
    @MainActor private func addError() {
        let newError =  InternalError(file: "ErrorsListView", function: "addError", appError: "added test error \(Int.random(in: 1...10))")
        ErrorManager.addError(error: newError, container: modelContext.container)
    }
}

#Preview {
    ErrorsListView().modelContainer(DataController.previewContainer).previewDevice("iPhone 15 Pro")
}
