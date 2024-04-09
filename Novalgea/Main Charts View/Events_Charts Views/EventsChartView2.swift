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
    
    @Binding var selectedCategories: Set<EventCategory>?
    @Binding var showNewCategoryView: Bool

    @State var showSelectionList = false
    @State var rawSelectedDate: Date?
    @State var showSelectedEventPopover = false
    
    var allCategories: [EventCategory]
    var categoriesShown: [EventCategory]
    
    private var filteredEvents: [DiaryEvent] {
        
        guard selectedCategories != nil else { return events }
        
        guard (selectedCategories?.count ?? 0) > 0 else { return events }
        
        var eventsInScope = [DiaryEvent]()
        
        for category in selectedCategories ?? [] {
            eventsInScope.append(contentsOf: category.relatedDiaryEvents ?? [])
        }
        
        return eventsInScope
        
//        return events.filter { event in
//            if selectedCategories!.contains(event.category) { return true }
//            else { return false }
//        }
    }

    var fromDate: Date
    var toDate: Date
    
    init(selectedCategories: Binding<Set<EventCategory>?>, showNewCategoryView: Binding<Bool> ,allCategories: [EventCategory], from: Date, to: Date) {
        
        _events = Query(filter: #Predicate<DiaryEvent> {
            $0.date >= from &&
            $0.date <= to
        }, sort:\DiaryEvent.date)

        _selectedCategories = selectedCategories
        _showNewCategoryView = showNewCategoryView
        
        self.fromDate = from
        self.toDate = to
        self.allCategories = allCategories
        self.categoriesShown = selectedCategories.wrappedValue == nil ? allCategories : Array(selectedCategories.wrappedValue!)

    }


    var body: some View {
        
        VStack(alignment: .leading) {
                
            //MARK: - chart
            Text(UserText.term("Events")).font(.title2).bold()
            HStack {
                ListPopoverButton_E(showSelectionList: $showSelectionList, selectedCategories: $selectedCategories, showNewCategoryView: $showNewCategoryView, allCategories: allCategories)
                Spacer()
                Text(fromDate.formatted(.dateTime.day().month()) + " - " + toDate.formatted(date: .abbreviated, time: .omitted)).foregroundStyle(.secondary)
                    .padding(.bottom, -5).font(.footnote)
            }

            Divider()
            
            Chart(categoriesShown, id: \.self) { category in
                let events = filteredEvents.filter { event in
                    if event.category == category { return true }
                    else { return false }
                }
                
                BarMark(x: .value("Category", category.name),y: .value("Count", events.count))
                    .foregroundStyle(by: .value("Category", category.name))
                
            }
            .chartPlotStyle { plotArea in
               plotArea
                   .frame(minHeight: 150)
                   .frame(maxHeight: 300)
            }
            .padding(.trailing)
            .transition(.move(edge: .leading))
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
