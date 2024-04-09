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
    
    @Binding var selectedCategories: Set<EventCategory>?
    @Binding var selectedEvent: DiaryEvent?
    @Binding var showNewCategoryView: Bool

    @State var showSelectionList = false
    @State var rawSelectedDate: Date?
    @State var showSelectedEventPopover = false
    
    var allCategories: [EventCategory]
    
    private var filteredEvents: [DiaryEvent] {
        
        guard selectedCategories != nil else { return events }
        
        guard (selectedCategories?.count ?? 0) > 0 else { return events }
        
        //not sure what's quicker - doesn't look like much dfference
//        return events.filter { event in
//            if event.category == nil { return false }
//            else if selectedCategories!.contains(event.category!) { return true }
//            else { return false }
//        }
        
        var eventsInScope = [DiaryEvent]()
        for category in selectedCategories ?? [] {
            eventsInScope.append(contentsOf: category.relatedDiaryEvents ?? [])
        }
        
        return eventsInScope
    }

    var fromDate: Date
    var toDate: Date
    var categoryChartLines: [String: Int]
    
    var eventSelectionTimeAdjustment: TimeInterval {
        let displayTime = toDate.timeIntervalSince(fromDate)
        if displayTime < 7*24*3600 { // day
            return 4*3600
        } else if displayTime < 365*24*3600/12 { // week
            return 12*3600
        }
        else {
            return 24*3600
        }
    }
    
    init(selectedCategories: Binding<Set<EventCategory>?>, showNewCategoryView: Binding<Bool> ,selectedDiaryEvent: Binding<DiaryEvent?>, allCategories: [EventCategory], from: Date, to: Date) {
        
        _events = Query(filter: #Predicate<DiaryEvent> {
            $0.date >= from &&
            $0.date <= to
        }, sort:\DiaryEvent.date)

        _selectedCategories = selectedCategories
        _selectedEvent = selectedDiaryEvent
        _showNewCategoryView = showNewCategoryView
        
        self.fromDate = from
        self.toDate = to
        self.allCategories = allCategories     
        
        var line = 1
        categoryChartLines = [String: Int]()
        for cat  in allCategories {
            categoryChartLines[cat.name] = line
            line += 1
        }
    }


    var body: some View {
        
        VStack(alignment: .leading) {
            Text(UserText.term("Diary events")).font(.title2).bold()
//            Text(fromDate.formatted(.dateTime.day().month()) + " - " + toDate.formatted(date: .abbreviated, time: .omitted)).foregroundStyle(.secondary).font(.caption)
            ListPopoverButton_E(showSelectionList: $showSelectionList, selectedCategories: $selectedCategories, showNewCategoryView: $showNewCategoryView, allCategories: allCategories)

            //MARK: - chart
            Chart(filteredEvents) { event in
                
                if selectedEvent != nil {
                    RuleMark(x: .value("", selectedEvent!.date))
                        .foregroundStyle(.primary)
                        .lineStyle(StrokeStyle(lineWidth: 1))
                }
                if event.endDate == event.date || event.endDate == nil {
                    PointMark(x: .value("Date", event.date),y: .value("", categoryChartLines[event.category!.name] ?? 0))
                        .foregroundStyle(by: .value("Category", event.category!.name))
                        .symbolSize(400)
                        .annotation(position: .overlay, alignment: .center, spacing: 0) {
                            Text(verbatim: String(event.category!.name.first!))
                                .font(.caption).bold()
                                .foregroundStyle(.white)
                        }
                }
                else {
                    RectangleMark(
                        xStart: .value("Start", event.date),
                        xEnd: .value("End", event.chartDisplayEndDate(defaultDuration: 1*3600)),
                        yStart: .value("", categoryChartLines[event.category!.name] ?? 0),
                        yEnd: .value("", categoryChartLines[event.category!.name]!+1)
                    )
                    .foregroundStyle(by: .value("Category", event.category!.name))
                    .annotation(position: .overlay, alignment: .center, spacing: 0) {
                        Text(verbatim: String(event.category!.name.first!))
                            .font(.caption).bold()
//                                    .foregroundStyle(by: .value("Category", event.category!.name))
                    }

                }
                
            }
            .chartPlotStyle { plotArea in
               plotArea
                   .frame(minHeight: 150)
                   .frame(maxHeight: 250)
            }
            .chartYAxis(.hidden)
            .chartXScale(domain: fromDate...toDate)
            .padding(.trailing)
            .chartOverlay { proxy in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .onTapGesture { location in
                        guard let value: (Date, Int) = proxy.value(at: location) else {
                            return
                        }
                        //Check if value is included in the data from the chart
                        for event in filteredEvents {
                            if (event.date.addingTimeInterval(-eventSelectionTimeAdjustment) ... event.date.addingTimeInterval(eventSelectionTimeAdjustment)).contains(value.0) {
                                if categoryChartLines[event.category!.name] == value.1 {
                                    selectedEvent = event
                                    showSelectedEventPopover = true
                                    return
                                }
                            }
                        }
                    }
            }
            .transition(.move(edge: .leading))
            
        }
        .overlay {
            if filteredEvents.isEmpty {
                ContentUnavailableView {
                    Label(UserText.term("No events for this time period"), systemImage: "square.and.pencil.circle").imageScale(.medium).font(.body)
                } description: {
                    Text("")
                }
            }
        }

    }
    
}

//#Preview {
//    EventsChartView(from: Date().addingTimeInterval(-30*24*3600), to: .now)
//}
