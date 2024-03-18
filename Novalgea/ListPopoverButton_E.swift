//
//  ListPopoverButton_E.swift
//  Novalgea
//
//  Created by aDev on 18/03/2024.
//

import SwiftUI




struct ListPopoverButton_E: View {
    
    @Binding var showSelectionList: Bool
    @Binding var selectedCategories: Set<String>?
    
    var allCategories: [String]

    var body: some View {
        
        HStack {
            //MARK: - category selection button
            Button {
                showSelectionList = true
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal.circle")
                        .imageScale(.large)
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
                            Label("", systemImage: "pills.circle.fill")
                        } description: {
                            Text(UserText.term("No event categories yet"))
                        }
                        
                        Button(UserText.term("Add one")) {
                            print("new event category")
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
                                    selectedCategories = Set<String>()
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
                                    Text(allCategories[index]).font(.footnote)
                                }
                            }
                            Divider()
                            
                        }
                        Button(UserText.term("Add category")) {
                            print("new event category")
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
    ListPopoverButton_E(showSelectionList: .constant(true), selectedCategories: .constant(["Cat1, Cat2"]), allCategories: ["Cat1, Cat2, Cat3"])
}
