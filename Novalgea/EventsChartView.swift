//
//  EventsChartView.swift
//  Novalgea
//
//  Created by aDev on 02/03/2024.
//

import SwiftUI
import SwiftData
import Charts
import OSLog

struct EventsChartView: View {
    
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \DiaryEvent.date) var events: [DiaryEvent]
    
    @Binding var selectedCategory: String?
    var allCategories: [String]

    var fromDate: Date
    var toDate: Date
    
    init(selectedCategory: Binding<String?>, allCategories: [String], from: Date, to: Date) {
        
        if let cat = selectedCategory.wrappedValue {
            _events = Query(filter: #Predicate<DiaryEvent> {
                $0.category == cat &&
                $0.date >= from &&
                $0.date <= to
            }, sort:\DiaryEvent.date)
            
        } else {
            _events = Query(filter: #Predicate<DiaryEvent> {
                $0.date >= from &&
                $0.date <= to
            }, sort:\DiaryEvent.date)
        }
                
        _selectedCategory = selectedCategory
        self.fromDate = from
        self.toDate = to
        self.allCategories = Array(allCategories.dropFirst())
        
    }


    var body: some View {
        
        ZStack {
            VStack(alignment: .leading) {
                Menu {
                    ForEach(allCategories.sorted(), id: \.self) {
                        category in
                        
                        HStack {
                            
                            Button(action: {
                                if selectedCategory == category {
                                    selectedCategory = nil
                                } else {
                                    selectedCategory = category
                                }
                            }, label: {
                                HStack {
                                    Text(category)
                                    if selectedCategory == category {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            })
                        }
                    }
                    
                } label: {
                    HStack {
                        Text(UserText.term("Show: ") + (selectedCategory ?? UserText.term("All")))
                        Image(systemName: "ellipsis.circle")
                    }
                }

                let _ = print("\(events.count) events filtered")
                Chart(events) { event in
                    RectangleMark(
                        xStart: .value("Start", event.date),
                        xEnd: .value("End", event.chartDisplayEndDate(defaultDuration: 1*3600)),
                        yStart: .value("", 0),
                        yEnd: .value("", 10)
                    )
                    .foregroundStyle(by: .value("Category", event.category))
                    
                }
                .chartXScale(domain: fromDate...toDate)
                .chartYScale(domain: 0...10)
                .opacity(0.5)
            }
        }
    }
}

//#Preview {
//    EventsChartView(from: Date().addingTimeInterval(-30*24*3600), to: .now)
//}
