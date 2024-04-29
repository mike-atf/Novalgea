//
//  MonthYearPicker.swift
//  Novalgea
//
//  Created by aDev on 23/04/2024.
//

import SwiftUI


struct YearMonthPickerView: View {
    
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedDate: Date
    @Binding var endDate: Date?

    var timeToEndDate: TimeInterval = 0
    let months: [String] = Calendar.current.shortMonthSymbols
    let columns = [ GridItem(.adaptive(minimum: 80)) ]
    
        
    var body: some View {
        
        VStack {
            //year picker
            HStack {
                
                Button {
                    var dateComponent = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: selectedDate)
                    dateComponent.year! -= 1
                    selectedDate = Calendar.autoupdatingCurrent.date(from: dateComponent)!
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Text(selectedDate, format: Date.FormatStyle().year())
                    .padding(.horizontal)
                    .bold()
                    .transition(.move(edge: .trailing))
                
                Button {
                    var dateComponent = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: selectedDate)
                    dateComponent.year! += 1
                    selectedDate = Calendar.autoupdatingCurrent.date(from: dateComponent)!
                } label: {
                    Image(systemName: "chevron.right")
                }

            }.padding(15)
            
            //month picker
            LazyVGrid(columns: columns, spacing: 10) {
               ForEach(months, id: \.self) { item in
                    Text(item)
                    .font(.headline)
                    .frame(width: 60, height: 33)
                    .bold()
                    .background(item == months[selectedDate.month()-1] ?  Color.green : Color.clear)
                    .cornerRadius(6)
                    .onTapGesture {
                        var dateComponent = Calendar.autoupdatingCurrent.dateComponents([.year, .month, .day], from: selectedDate)
                        dateComponent.day = 1
                        dateComponent.month = (months.firstIndex(of: item)! + 1)
                        dateComponent.year = selectedDate.year()
                        selectedDate = Calendar.autoupdatingCurrent.date(from: dateComponent)!
                        endDate = selectedDate.addingTimeInterval(timeToEndDate)
                        dismiss()
                    }
               }
            }
            .padding(.horizontal)
            
            Button {
                let startEnd = DatesManager.monthStartAndEnd(ofDate: .now)
                selectedDate = startEnd.first!
                endDate = startEnd.last!
                dismiss()
            } label: {
                Text(UserText.term("Today"))
            }
            .buttonStyle(BorderedProminentButtonStyle())

        }
    }
}

#Preview {
    YearMonthPickerView(selectedDate: .constant(Date.now), endDate: .constant(nil))
}

