//
//  NewEventView.swift
//  Novalgea
//
//  Created by aDev on 03/04/2024.
//


import SwiftUI
import SwiftData
import OSLog

struct NewEventView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query var existingCategories: [EventCategory]
    
    private var categories: [EventCategory] {
        var extended = existingCategories
        extended.append(EventCategory.addNew)
        return extended
    }

    @Binding var selectedEvent: DiaryEvent?
    @Binding var createNew: Bool

    @State var category: EventCategory = EventCategory.addNew
    @State var notes = String()
    @State var startDate: Date = .now
    @State var endDate: Date? = nil
    @State var backdatingOption = BackdatingTimeOptions.isNow
    @State var showNewCategoryView = false

    @State var showDateSelector = false
    
    @State var showAlert = false
    @State var alertMessage = String()

    @FocusState private var focused: Bool
        
    var body: some View {
        
            List {
                let text = createNew ? UserText.term("New event") : UserText.term("Edit event")
                Text(text).font(.title).bold()

                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "square.and.pencil.circle.fill").imageScale(.large).foregroundColor(.orange)
                        Text(UserText.term("Description"))
                    }
                    TextEditor(text: $notes)
                        .font(.footnote)
                        .focused($focused)
                    //TODO: - this is somewhat improvised as .toolBar won't show any keyboard 'done' button whatsoever
                        .keyboardType(.webSearch)
                        .onChange(of: notes, { oldValue, newValue in
                            if newValue.last == "\n" {
                                notes = oldValue
                                focused = false
                            }
                        })
                }
                .frame(minHeight: 140)
                
                Picker(selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        HStack {
                            Text(cat.name).tag(cat as EventCategory?)
                            Spacer()
                            Text(cat.symbol).tag(cat as EventCategory?)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "list.bullet.circle.fill").foregroundStyle(.orange).imageScale(.large)
                        Text("Category")
                    }
                }
                .onChange(of: category) { oldValue, newValue in
                    if category.name == "Add new" {
                        showNewCategoryView = true
                        category = selectedEvent?.category ?? categories.first! // in case user cancels new category
                    }
               }
            
                Section {
                    
                    Picker(selection: $backdatingOption) {
                        ForEach(BackdatingTimeOptions.allCases, id: \.self) { option in
                            Text(option.rawValue)
                        }
                    } label: {
                        VStack{
                            HStack {
                                Image(systemName: "calendar.circle.fill").imageScale(.large).foregroundStyle(.orange)
                                Text(UserText.term("Select time and date")).font(.title3).bold()
                            }
                        }
                    }
                    .pickerStyle(.inline)
                    .onChange(of: backdatingOption) {
                        focused = false
                        switch backdatingOption {
                        case .isNow:
                            startDate = Date()
                        case .halfHourAgo:
                            startDate = .now.addingTimeInterval(-1800)
                        case .oneHourAgo:
                            startDate = .now.addingTimeInterval(-3600)
                        case .twoHoursAgo:
                            startDate = .now.addingTimeInterval(-7200)
                        case .custom:
                            if createNew {
                                showDateSelector = true
                            }
                        }
                    }
                    
                    if backdatingOption == .custom {
                        DatePicker("Start", selection: $startDate)
                            .pickerStyle(.inline)
                    }
                    
                    HStack {
                        let text2 = endDate == nil ? UserText.term("End (optional)") : UserText.term("End")
                        if endDate != nil {
                            Button(action: {
                                endDate = nil
                            }, label: {
                                Image(systemName: "x.circle")
                                    .tint(.red)
                            })
                        }
                        
                        DatePicker(text2, selection: Binding<Date>(get: {self.endDate ?? startDate.addingTimeInterval(3600)}, set: {self.endDate = $0}), in: startDate...)
                            .pickerStyle(.inline)
                    }
                }
                
                
                Section {
                    Button {
                        
                        guard category.name != UserText.term("Add new") else {
                            alertMessage = UserText.term("Please select a category before saving")
                            showAlert = true
                            return
                        }
                        
                        save()
                    } label: {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .font(Font.title2.bold())
                            .foregroundColor(.white)
                    }
                    .listRowBackground(notes == "" ? Color.gray: Color.blue)
                    .disabled(notes == "")
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
            .popover(isPresented: $showDateSelector) {
                VStack {
                    Text(UserText.term("Start of event")).font(.title).bold()
                    DatePicker("", selection: $startDate)
                        .datePickerStyle(.graphical)
                    Button(UserText.term("Done")) {
                        showDateSelector = false
                    }.buttonStyle(BorderedProminentButtonStyle())
                }
                .padding()
            }
            .onAppear {
                if categories.count > 1 { // default is "Add new"
                    focused = true
                    category = categories.first!
                }
            }
            .sheet(isPresented: $showNewCategoryView) {
                NewCategoryView(createNew: true)
            }
            .alert(UserText.term("There's a problem"), isPresented: $showAlert) {
                
            } message: {
                Text(alertMessage)
            }
            .onChange(of: existingCategories) { oldValue, newValue in
                category = existingCategories.last!
            }
            .onChange(of: selectedEvent, { _, newValue in
                // required as otherwise (on iPad) changing the list view selection -> selectedEvent does not update Texts and Pickers as selectedEvent is not used directly in these
                if newValue != nil {
                    if !createNew {
                        withAnimation {
                            category = selectedEvent?.category ?? EventCategory.placeholder
                            notes = selectedEvent?.notes ?? ""
                            startDate = selectedEvent?.date ?? .now
                            endDate = selectedEvent?.endDate
                            backdatingOption = .custom
                        }
                    }
                }
            })
            .onAppear {
                if !createNew {
                    category = selectedEvent?.category ?? EventCategory.placeholder
                    notes = selectedEvent?.notes ?? ""
                    startDate = selectedEvent?.date ?? .now
                    endDate = selectedEvent?.endDate
                    backdatingOption = .custom
                }
            }
    }
    
    private func save() {
        if createNew {
            
            let new = DiaryEvent(date: startDate, endDate: endDate, category: category, notes: notes)
            modelContext.insert(new)
        }
        else {
            selectedEvent?.notes = notes
            selectedEvent?.category = category
            selectedEvent?.date = startDate
            selectedEvent?.endDate = endDate
        }
        
        selectedEvent = nil
        dismiss()
    }
    
    private func cancel() {
        selectedEvent = nil
        dismiss()
    }

}

#Preview {
    NewEventView(selectedEvent: .constant(DiaryEvent.preview), createNew: .constant(false), category: EventCategory.preview).modelContainer(DataController.previewContainer)
}
