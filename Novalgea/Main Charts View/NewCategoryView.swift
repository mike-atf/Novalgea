//
//  NewCategoryView.swift
//  Novalgea
//
//  Created by aDev on 28/03/2024.
//

import SwiftUI
import SwiftData

struct NewCategoryView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \EventCategory.name) var categories: [EventCategory]
    
    @Binding var showView: Bool
    @Binding var newCategorySelection: EventCategory?
    
    @FocusState private var focused: Bool

    @State var newCategory = String()
    @State var nonunique = String()
    @State var alertMessage = String()
    @State var showAlert = false
    @State var saveDisabled = true

    var body: some View {
        
        Form {
            Section {
                Text(UserText.term("New event category")).font(.title).bold()
                Text(UserText.term("Please chose a unique name"))
                TextField(UserText.term("Name"), text: $newCategory)
                    .focused($focused)
                    .onSubmit {
                        if categories.compactMap({ $0.name }).contains(newCategory) {
                            nonunique = newCategory
                            newCategory = String()
                            alertMessage = UserText.term("\(nonunique) already exists. Please chose another name.")
                            showAlert = true
                        } else {
                            save()
                        }
                    }
            }
            
            if !categories.isEmpty {
                Section {
                    Text(UserText.term("Existing categories")).font(.title3).bold()
                    ForEach(categories) {
                        Text($0.name)
                    }
                }
            }

            Section {
                    Button {
                        save()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(Font.title2.bold())
                            .foregroundColor(.white)
                    }
                    .listRowBackground(newCategory == "" ? Color.gray: Color.blue)
                    .disabled(newCategory == "")
            }
            
            Section {
                Button {
                    cancel()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(Font.title2.bold())
                        .foregroundColor(.red)
                }
            }

        }
        .onAppear {
            focused = true
        }
        
    }
        
    private func save() {
        
        guard newCategory != "" else { return }
        let new = EventCategory(name: newCategory)
        modelContext.insert(new)
        newCategorySelection = new
        showView = false
    }
    
    private func cancel() {
        showView = false
    }


}

#Preview {
    NewCategoryView(showView: .constant(true), newCategorySelection: .constant(EventCategory.preview)).modelContainer(DataController.previewContainer)
}
