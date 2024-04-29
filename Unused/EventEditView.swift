//
//  EventEditView.swift
//  Novalgea
//
//  Created by aDev on 19/04/2024.
//

import SwiftUI
import SwiftData

/*
struct EventEditView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @Query var existingCategories: [EventCategory]
    
    @Binding var event: DiaryEvent?
    @Binding var path: NavigationPath
    
    @State var showNewCategoryView: Bool = false
    @State var showNewCategoryViewFromMainView: Bool = false

    @State var originalEvent = DiaryEvent.placeHolder

    @State var showDateSelector = false
    @State var addNewCategory = EventCategory.addNew
    
    @State var newDescription = String()
    @State var newDate = Date.now
    @State var newEndDate: Date?

    @State var showAlert = false
    @State var alertMessage = String()
    @State var selectedCategory: EventCategory = EventCategory.addNew // because Picker will not work with '$event.category' even with using .tag(Optional($0))

    @FocusState private var focused: Bool
    
//    var categoryListWithAdd: [EventCategory] {
//        var existing = existingCategories
//        existing.append(EventCategory.addNew)
//        return existing
//    }
    
        
    var body: some View {
        
            List {
                Text(UserText.term("Edit diary event")).font(.title).bold()
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "square.and.pencil.circle.fill").imageScale(.large).foregroundColor(.orange)
                        Text(UserText.term("Description"))
                    }
                    TextEditor(text: $newDescription)
                        .focused($focused)
                    //TODO: - this is somewhat improvised as .toolBar won't show any keyboard 'done' button whatsoever
                        .keyboardType(.webSearch)
                        .onChange(of: newDescription, { oldValue, newValue in
                            if newValue.last == "\n" {
                                focused = false
                            }
                        })
                }
                .frame(minHeight: 150)
                
                Picker(selection: $selectedCategory) {
                    ForEach(existingCategories, id:\.self) { cat in
                        HStack {
                            Text(cat.name)
                            Spacer()
                            Text(cat.symbol)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "list.bullet.circle.fill").foregroundStyle(.orange).imageScale(.large)
                        Text("Category")
                    }
                }
                .onChange(of: selectedCategory) { oldValue, newValue in
                    if selectedCategory.name == UserText.term("Add new") {
                        showNewCategoryView = true
                        event?.category = originalEvent.category // in case user cancels new category
                    }
               }
                
                Section {
                    
                    DatePicker(UserText.term("Event date"), selection: $newDate)
                                        
                }
        
                Section {
                    
                    let text = newEndDate == nil ? UserText.term("End (optional)") : UserText.term("Current end")
                    HStack {
                        Text(text)
                        
                        if newEndDate != nil {
                            Button(action: {
                                newEndDate = nil
                            }, label: {
                                Image(systemName: "minus.circle")
                                    .tint(.red)
                            })
                        }
                        
                        DatePicker("", selection: Binding<Date>(get: { newEndDate ?? .now }, set: { newEndDate = $0}), in: newDate...)
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
                    .buttonStyle(BorderedProminentButtonStyle())
                    .disabled((event?.notes ?? "") == "")
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal)
            .alert(UserText.term("There's a problem"), isPresented: $showAlert) {
                
            } message: {
                Text(alertMessage)
            }
            .onAppear(perform: {
                selectedCategory = event?.category ?? existingCategories.first!
                newDescription = event?.notes ?? ""
                newDate = event?.date ?? .now
                newEndDate = event?.endDate
                if let event {
                    originalEvent = event
                }
            })
        
    }
    
    private func save() {
                                
        event?.notes = newDescription
        event?.date = newDate
        event?.endDate = newEndDate
        event?.category = selectedCategory.name == UserText.term("Add new") ? existingCategories.last : selectedCategory

        do {
            try modelContext.save()
        } catch {
            let ierror = InternalError(file: "EventEditView", function: "save()", appError: "error trying to save edited event", osError: error.localizedDescription)
            DispatchQueue.main.async {
                ErrorManager.addError(error: ierror, container: modelContext.container)
            }
        }
        
        
        event = nil
        path = NavigationPath()
    }
    
    private func cancel() {
        event = originalEvent
        path = NavigationPath()
    }
}

#Preview {
    EventEditView(event: .constant(DiaryEvent.preview), path: .constant(NavigationPath()), selectedCategory: EventCategory.preview).modelContainer(DataController.previewContainer)
}
*/
