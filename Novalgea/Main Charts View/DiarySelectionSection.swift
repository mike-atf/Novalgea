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
    @Binding var selectedEvent: DiaryEvent?
    @Binding var selectedEventIndex: Int?
    
    var body: some View {
        
        VStack {
            Picker("Show", selection: $selectedDisplayTime) {
                
                ForEach(DisplayTimeOption.allCases) { option in
                    Text(option.rawValue).tag(option)
               }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedDisplayTime) { oldValue, newValue in
                
                withAnimation {
                    switch selectedDisplayTime {
                    case .day:
                        startDisplayDate = DatesManager.startOfDay(from: startDisplayDate, _by: 0)
                        endDisplayDate = startDisplayDate.addingTimeInterval(24*3600-1)
                    case .week:
                        startDisplayDate = DatesManager.startOfWeek(from: startDisplayDate, _by: 0)
                        endDisplayDate = DatesManager.startOfWeek(from: startDisplayDate, _by: 1).addingTimeInterval(-1)
                    case .month:
                        startDisplayDate = DatesManager.startOfMonth(from: startDisplayDate, _by: 0)
                        endDisplayDate = DatesManager.startOfMonth(from: startDisplayDate, _by: 1).addingTimeInterval(-1)
                    case .quarter:
                        startDisplayDate = DatesManager.startOfQuarter(from: startDisplayDate, _by: 0)
                        endDisplayDate = DatesManager.startOfQuarter(from: startDisplayDate, _by: 1).addingTimeInterval(-1)
                    case .year:
                        startDisplayDate = DatesManager.startOfYear(from: startDisplayDate, _by: 0)
                        endDisplayDate = DatesManager.startOfYear(from: startDisplayDate, _by: 1).addingTimeInterval(-1)
                    }

                }
                
                selectedEvent = nil
                selectedEventIndex = nil
            }

        }

    }
}

//#Preview {
//    DiarySelectionSection()
//}
