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
                startDisplayDate = endDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
            }

        }

    }
}

//#Preview {
//    DiarySelectionSection()
//}
