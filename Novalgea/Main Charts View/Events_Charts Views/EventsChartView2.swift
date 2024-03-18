//
//  EventsChartView2.swift
//  Novalgea
//
//  Created by aDev on 13/03/2024.
//

import SwiftUI
import SwiftData
import Charts
import OSLog

struct EventsChartView2: View {
    
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \DiaryEvent.date) var events: [DiaryEvent]
    
    @Binding var selectedCategories: Set<String>?

    @State var showSelectionList = false
    @State var rawSelectedDate: Date?
    @State var showSelectedEventPopover = false
    var allCategories: [String]
    var categoriesShown: [String]
    
    private var filteredEvents: [DiaryEvent] {
        
        guard selectedCategories != nil else { return events }
        
        guard (selectedCategories?.count ?? 0) > 0 else { return events }
        
        return events.filter { event in
            if selectedCategories!.contains(event.category) { return true }
            else { return false }
        }
    }

    var fromDate: Date
    var toDate: Date
    
    init(selectedCategories: Binding<Set<String>?>, allCategories: [String], from: Date, to: Date) {
        
        _events = Query(filter: #Predicate<DiaryEvent> {
            $0.date >= from &&
            $0.date <= to
        }, sort:\DiaryEvent.date)

        _selectedCategories = selectedCategories
        
        self.fromDate = from
        self.toDate = to
        self.allCategories = allCategories
        self.categoriesShown = selectedCategories.wrappedValue == nil ? allCategories : Array(selectedCategories.wrappedValue!)
        
    }


    var body: some View {
        
        VStack(alignment: .leading) {
                
            //MARK: - chart
            Text(UserText.term("Events")).font(.title2).bold()
            Text(fromDate.formatted(.dateTime.day().month()) + " - " + toDate.formatted(date: .abbreviated, time: .omitted)).foregroundStyle(.secondary)
                .padding(.bottom, -5)
            Divider()
               
            ListPopoverButton_E(showSelectionList: $showSelectionList, selectedCategories: $selectedCategories, allCategories: allCategories)

            Divider()
            
            Chart(categoriesShown, id: \.self) { category in
                let events = filteredEvents.filter { event in
                    if event.category == category { return true }
                    else { return false }
                }
                
                BarMark(x: .value("Category", category),y: .value("Count", events.count))
                    .foregroundStyle(by: .value("Category", category))
                
            }
            .padding(.trailing)
//            .chartOverlay { proxy in
//                Rectangle().fill(.clear).contentShape(Rectangle())
//                    .onTapGesture { location in
//                        guard let value: (Date, Int) = proxy.value(at: location) else {
//                            return
//                        }
//                    }
//            }
            
        }
    }
    
}
