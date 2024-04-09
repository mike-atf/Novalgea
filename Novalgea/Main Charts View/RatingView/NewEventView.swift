//
//  NewEventView.swift
//  Novalgea
//
//  Created by aDev on 03/04/2024.
//


import SwiftUI
import SwiftData

struct NewEventView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    var categories: [EventCategory]
    
    @Binding var showView:Bool
    
    @State var category: EventCategory?
    @State var notes = String()
    @State var startDate: Date = .now
    @State var endDate: Date? = nil
    @State var backdatingOption = BackdatingTimeOptions.isNow
    @State var showNewCategoryView = false

    @State var showDateSelector = false
    @State var addNewCategory = EventCategory(name: "Add")
    
    @State var showAlert = false
    @State var alertMessage = String()


    @FocusState private var focused: Bool
    
    init(categories: [EventCategory], showView: Binding<Bool>, category: EventCategory? = nil) {
        self.categories = categories
        _showView = showView
        self.category = category
        
        if categories.count > 0 { // if 0 then the nicer 'Add new' VStack is shown
            self.categories.append(EventCategory(name: "Add new"))
        }
    }
    
    var body: some View {
        
            List {
                Text(UserText.term("New diary event")).font(.title).bold()
                
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "square.and.pencil.circle.fill").imageScale(.large).foregroundColor(.orange)
                        Text(UserText.term("Description"))
                    }
                    TextEditor(text: $notes)
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
                .frame(minHeight: 100)
                
                if !categories.isEmpty {

                    Picker(selection: $category) {
                        ForEach(categories) {
                            Text($0.name).tag($0 as EventCategory?)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet.circle.fill").foregroundStyle(.orange).imageScale(.large)
                            Text("Category")
                        }
                    }
                    .onChange(of: category) { oldValue, newValue in
                        if category?.name == "Add new" {
                            showNewCategoryView = true
                            category = categories.first // in case user cancels new category
                        }
                   }
                } else {
                    VStack {
                        ContentUnavailableView {
                            Label("", systemImage: "square.and.pencil.circle.fill")
                        } description: {
                            Text(UserText.term("No event category yet"))
                        }
                        
                        Button(UserText.term("Add a category")) {
                            showNewCategoryView = true
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                    .presentationCompactAdaptation(.none)
                    .padding()

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
                            Text(startDate.formatted())
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
                            showDateSelector = true
                        }
                    }
                    
                }
                
                DatePicker(UserText.term("End date (optional)"), selection: Binding<Date>(get: {self.endDate ?? startDate.addingTimeInterval(3600)}, set: {self.endDate = $0}), in: startDate...)
                
                Section {
                    Button {
                        
                        guard category != nil else {
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
                if !categories.isEmpty {
                    focused = true
                    category = categories.first
                }
            }
            .sheet(isPresented: $showNewCategoryView) {
                NewCategoryView(showView: $showNewCategoryView, newCategorySelection: $category)
            }
            .alert(UserText.term("There's a problem"), isPresented: $showAlert) {
                
            } message: {
                Text(alertMessage)
            }
        
//            .toolbar {
//                ToolbarItemGroup(placement: .keyboard) {
//                    Button("Done") {
//                        print("done!")
//                    }
//                }
//            }

    }
    
    private func save() {
                                
        let new = DiaryEvent(date: startDate, endDate: endDate, category: category!, notes: notes)
        modelContext.insert(new)
        showView = false
    }
    
    private func cancel() {
        showView = false
    }

}

//#Preview {
//    NewEventView(showView: .constant(true), category: EventCategory.preview).modelContainer(DataController.previewContainer)
//}
