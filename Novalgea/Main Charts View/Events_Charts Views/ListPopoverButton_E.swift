//
//  ListPopoverButton_E.swift
//  Novalgea
//
//  Created by aDev on 18/03/2024.
//

import SwiftUI




struct ListPopoverButton_E: View {
    
    @Binding var showSelectionList: Bool
    @Binding var selectedCategories: Set<EventCategory>?    
    @Binding var showNewCategoryView: Bool
    
    var allCategories: [EventCategory]

    var body: some View {
        
        HStack {
            //MARK: - category selection button
            Button {
                showSelectionList = true
            } label: {
                HStack {
                    Image(systemName: "eye.circle.fill")
                        .imageScale(.medium)
                    if selectedCategories?.count ?? 0 > 0 {
                        Text(UserText.term("Categories: ") + "\(selectedCategories!.count)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    } else {
                        Text(UserText.term("Categories: ") + UserText.term("All"))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .popover(isPresented: $showSelectionList) {
                
                if allCategories.count == 0 {
                    VStack {
                        ContentUnavailableView {
                            Label("", systemImage: "square.and.pencil.circle.fill")
                        } description: {
                            Text(UserText.term("No event categories yet"))
                        }
                        
                        Button(UserText.term("Add one")) {
                            showSelectionList = false
                            showNewCategoryView = true
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                    .padding()
                    .presentationCompactAdaptation(.none)
                } else {
                    
                    VStack(alignment: .leading) {
                        
                        ForEach(allCategories.indices, id: \.self) { index in
                            Button {
                                if selectedCategories == nil {
                                    selectedCategories = Set<EventCategory>()
                                    selectedCategories!.insert(allCategories[index])
                                }
                                else if selectedCategories!.contains(allCategories[index]) {
                                    selectedCategories!.remove(allCategories[index])
                                } else {
                                    selectedCategories!.insert(allCategories[index])
                                }
                            } label: {
                                HStack {
                                    if (selectedCategories == nil) {
                                        Image(systemName: "circle")
                                    } else if selectedCategories!.contains(allCategories[index]) {
                                        Image(systemName: "checkmark.circle.fill").symbolRenderingMode(.multicolor)
                                    } else {
                                        Image(systemName: "circle")
                                    }
                                    Text(allCategories[index].name).font(.footnote)
                                }
                            }
                            Divider()
                            
                        }
                        Button(UserText.term("Add category")) {
                            showSelectionList = false
                            showNewCategoryView = true
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                    .padding()
                    .presentationCompactAdaptation(.none)
                }
            }

        }

    }
}

#Preview {
    ListPopoverButton_E(showSelectionList: .constant(true), selectedCategories: .constant([EventCategory.preview]), showNewCategoryView: .constant(true), allCategories: [EventCategory.preview])
}
