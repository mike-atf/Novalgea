//
//  DiarySelectionSection.swift
//  Novalgea
//
//  Created by aDev on 29/02/2024.
//

import SwiftUI
import OSLog

struct DiarySelectionSection: View {
    
    @Binding var selectedDisplayTime: DisplayTimeOption
    @Binding var startDisplayDate: Date
    @Binding var endDisplayDate: Date
//    @Binding var selectedSingleCategory: String
//
//    @Binding var eventCategories: [String]
//    @Binding var categoriesDisplayed: [String]?
//
//    var symptoms: [Symptom]
//    @Binding var selectedSymptom: Symptom?

    var body: some View {
        
        VStack {
            Picker("Show", selection: $selectedDisplayTime) {
                
                ForEach(DisplayTimeOption.allCases) { option in
                    Text(option.rawValue).tag(option)
               }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedDisplayTime) { oldValue, newValue in
                startDisplayDate = endDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
            }

//            HStack {
//                Menu {
//                    ForEach(eventCategories.sorted(), id: \.self) {
//                        category in
//                        
//                        HStack {
//                            
//                            Button(action: {
//                                selectedSingleCategory = category
//                                if selectedSingleCategory == eventCategories[0] {
//                                    categoriesDisplayed = nil
//                                }
//                            }, label: {
//                                HStack {
//                                    Text(category)
//                                    if selectedSingleCategory == category {
//                                        Spacer()
//                                        Image(systemName: "checkmark")
//                                    }
//                                }
//                            })
//                        }
//                    }
//                    
//                } label: {
//                    HStack {
//                        Text(UserText.term("Categories: ") + selectedSingleCategory)
//                        Image(systemName: "ellipsis.circle")
//                    }
//                }
//            }
        }

    }
}

//#Preview {
//    DiarySelectionSection()
//}
