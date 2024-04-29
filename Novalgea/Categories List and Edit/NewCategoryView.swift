//
//  NewCategoryView.swift
//  Novalgea
//
//  Created by aDev on 28/03/2024.
//

import SwiftUI
import SwiftData
import OSLog

struct NewCategoryView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \EventCategory.name) var categories: [EventCategory]
    
    @Binding var forSelectedEvent: DiaryEvent?
    @Binding var selectedCategory: EventCategory?
    
    @FocusState private var focused: Bool

    @State var categoryName = String()
    @State var selectedSymbol = String()
    @State var selectedColor = Color(UIColor(named: "e0")!)
    @State var availableColors = ColorScheme.eventCategoryColorsArray
    @State var nonunique = String()
    @State var alertMessage = String()
    @State var showAlert = false
    @State var saveDisabled = true
    
    var createNew: Bool
    
    init(forSelectedEvent: Binding<DiaryEvent?>? = .constant(nil), selectedCategory: Binding<EventCategory?>? = .constant(nil), createNew: Bool) {
        _forSelectedEvent = forSelectedEvent!
        _selectedCategory = selectedCategory!
        
        self.createNew = createNew
    }

    
    var body: some View {
        
        Form {
            Section {
                VStack(alignment: .leading) {
                    let text1 = createNew ? UserText.term("New event category") : UserText.term("Edit event category")
                    let text2 = createNew ? UserText.term("Enter a unique name") : UserText.term("Change to a unique name")
                    Text(text1).font(.title).bold()
                    Text(text2).foregroundStyle(.secondary).font(.footnote)
                }
                TextField(UserText.term("Name"), text: $categoryName)
                    .focused($focused)
                    .onSubmit {
                        if categories.compactMap({ $0.name }).contains(categoryName) {
                            nonunique = categoryName
                            categoryName = String()
                            alertMessage = UserText.term("\(nonunique) already exists. Please chose another name.")
                            showAlert = true
                        } else {
                            save()
                        }
                    }
            }
            
            Section {                
                Picker(selection: $selectedSymbol) {
                    ForEach(SymbolScheme.eventCategorySymbols, id:\.self) {
                        Text($0)
                    }
                } label: {
                    Text(UserText.term("Symbol")).bold().font(.title3)
                }

            
            }
            
            Section {
                
                ColorSelectionPicker(selectedColor: $selectedColor, colorPalette: ColorScheme.eventCategoryColorsArray)
            }
            
            Section {
                if !categories.isEmpty {
                        Text(UserText.term("Existing categories & colors")).font(.title3).bold()
                        ForEach(categories, id: \.self) { cat in
                            HStack {
                                Text(cat.symbol)
                                Text(cat.name)
                                Spacer()
                                Circle()
                                    .fill(cat.color())
                                    .frame(width: 20)
                            }
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
                    .listRowBackground(categoryName == "" ? Color.gray: Color.blue)
                    .disabled(categoryName == "")
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
            selectedColor = createNew ? ColorManager.getNewCategoryColor(container: self.modelContext.container) : (selectedCategory?.color() ?? Color.primary)
            availableColors = getAvailableColors()
            
            if !createNew {
                categoryName = selectedCategory?.name ?? UserText.term("Name")
                selectedSymbol = selectedCategory?.symbol ?? SymbolScheme.eventCategorySymbols.randomElement()!
            }
        }
        
    }
    
    private func getAvailableColors() -> [Color] {
        // can't use this in 'onAppear' with @MainActor ColorManager  - error 'Cannot assign value of type '@MainActor (ModelContainer) -> [Color]' to type '[Color]'
        
        var available = [Color]()

        let usedColorsArray = categories.compactMap { $0.color() }
        
        var usedColors = Set<Color>()
        for color in usedColorsArray {
            usedColors.insert(color)
        }
        for eColor in ColorScheme.eventCategoryColorsArray {
            if !usedColors.contains(eColor) {
                available.append(eColor)
            }
        }
        return available.count == 0 ? ColorScheme.eventCategoryColorsArray : available
    }

        
    @MainActor private func save() {
        
        guard categoryName != "" else {
            alertMessage = UserText.term("Category name can't be emmpty. Please enter another")
            showAlert = true
            return
        }
        
        if createNew {
            let new = EventCategory(name: categoryName, symbol: selectedSymbol, color: selectedColor)
            modelContext.insert(new)
            forSelectedEvent?.category = new
            selectedCategory = new
        } else {
            selectedCategory?.name = categoryName
            selectedCategory?.setNewColor(color: selectedColor)
            selectedCategory?.symbol = selectedSymbol
        }
        
        selectedCategory = nil
        dismiss()
    }
    
    private func cancel() {
        selectedCategory = nil
        dismiss()
    }


}

#Preview {
    NewCategoryView(forSelectedEvent: .constant(DiaryEvent.preview), createNew: true).modelContainer(DataController.previewContainer)
}
