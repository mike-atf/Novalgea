//
//  BackdatingOptionView.swift
//  Novalgea
//
//  Created by aDev on 04/04/2024.
//

import SwiftUI

struct BackdatingOptionView: View {
    
    @Binding var selectedEventDate: Date
    
    @State var backdatingOption = BackdatingTimeOptions.isNow
    @State var showDateSelector = false
    
    var body: some View {
        
            
            Picker(selection: $backdatingOption) {
                ForEach(BackdatingTimeOptions.allCases, id: \.self) { option in
                        Text(option.rawValue)
                }
                if showDateSelector {
                    DatePicker(UserText.term(""), selection: $selectedEventDate, in: ...selectedEventDate)
                }

            } label: {
                VStack{
                    HStack {
                        Image(systemName: "calendar.circle.fill").imageScale(.large).foregroundStyle(.orange)
                        Text(UserText.term("Select time and date")).font(.title3).bold()
                    }
                    Text(selectedEventDate.formatted())
                }
            }
            .pickerStyle(.inline)
            .onChange(of: backdatingOption) {
                switch backdatingOption {
                case .isNow:
                    selectedEventDate = Date()
                case .halfHourAgo:
                    selectedEventDate = .now.addingTimeInterval(-1800)
                case .oneHourAgo:
                    selectedEventDate = .now.addingTimeInterval(-3600)
                case .twoHoursAgo:
                    selectedEventDate = .now.addingTimeInterval(-7200)
                case .custom:
                    showDateSelector = true
                }
            }
    }
}

#Preview {
    BackdatingOptionView(selectedEventDate: .constant(Date.now))
}
