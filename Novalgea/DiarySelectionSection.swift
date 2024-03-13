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

    var body: some View {
        
        VStack {
            Picker("Show", selection: $selectedDisplayTime) {
                
                ForEach(DisplayTimeOption.allCases) { option in
                    Text(option.rawValue).tag(option)
               }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedDisplayTime) { oldValue, newValue in
                
                startDisplayDate = startDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
                withAnimation {
                    switch selectedDisplayTime {
                    case .day:
                        let dates = DatesManager.dayStartAndEnd(ofDate: startDisplayDate)
                        startDisplayDate = dates.first!
                        endDisplayDate = dates.last!
                    case .week:
                        let dates = DatesManager.weekStartAndEnd(ofDate: startDisplayDate)
                        startDisplayDate = dates.first!
                        endDisplayDate = dates.last!
                    case .month:
                        let dates = DatesManager.monthStartAndEnd(ofDate: startDisplayDate)
                        startDisplayDate = dates.first!
                        endDisplayDate = dates.last!
                    case .quarter:
                        let dates = DatesManager.quarterStartAndEnd(ofDate: startDisplayDate)
                        startDisplayDate = dates.first!
                        endDisplayDate = dates.last!
                    case .year:
                        let dates = DatesManager.yearStartAndEnd(ofDate: startDisplayDate)
                        startDisplayDate = dates.first!
                        endDisplayDate = dates.last!
                    }
                }
            }

        }

    }
}

//#Preview {
//    DiarySelectionSection()
//}
