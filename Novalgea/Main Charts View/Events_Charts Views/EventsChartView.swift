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
    
    @Binding var selectedCategories: Set<String>?
    @Binding var selectedEvent: DiaryEvent?

    @State var showSelectionList = false
    @State var rawSelectedDate: Date?
    @State var showSelectedEventPopover = false
    var allCategories: [String]
    
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
    
    init(selectedCategories: Binding<Set<String>?>, selectedDiaryEvent: Binding<DiaryEvent?>,allCategories: [String], from: Date, to: Date) {
        
        _events = Query(filter: #Predicate<DiaryEvent> {
            $0.date >= from &&
            $0.date <= to
        }, sort:\DiaryEvent.date)

        _selectedCategories = selectedCategories
        _selectedEvent = selectedDiaryEvent
        
        self.fromDate = from
        self.toDate = to
        self.allCategories = allCategories     
        
        var line = 1
        categoryChartLines = [String: Int]()
        for cat  in allCategories {
            categoryChartLines[cat] = line
            line += 1
        }
    }


    var body: some View {
        
        VStack(alignment: .leading) {
            Text(UserText.term("Diary events")).font(.title3).bold()
            Text(fromDate.formatted(.dateTime.day().month()) + " - " + toDate.formatted(date: .abbreviated, time: .omitted)).foregroundStyle(.secondary).font(.caption)
//                .padding(.bottom, -5)

            //MARK: - chart
            Chart(filteredEvents) { event in
                
                if selectedEvent != nil {
                    RuleMark(x: .value("", selectedEvent!.date))
//                        .opacity(0.25)
                        .foregroundStyle(.gray)
                }
                if event.endDate == event.date {
                    PointMark(x: .value("Date", event.date),y: .value("", categoryChartLines[event.category] ?? 0))
                        .foregroundStyle(by: .value("Category", event.category))
                        .symbolSize(400)
                        .annotation(position: .overlay, alignment: .center, spacing: 0) {
                            Text(verbatim: String(event.category.first!))
                                .font(.caption).bold()
                                .foregroundStyle(.white)
                        }
                }
                else {
                    RectangleMark(
                        xStart: .value("Start", event.date),
                        xEnd: .value("End", event.chartDisplayEndDate(defaultDuration: 1*3600)),
                        yStart: .value("", categoryChartLines[event.category] ?? 0),
                        yEnd: .value("", categoryChartLines[event.category]!+1)
                    )
                    .foregroundStyle(by: .value("Category", event.category))
                }
                
            }
            .chartYAxis(.hidden)
//            .chartXAxis(.hidden)
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
                                if categoryChartLines[event.category] == value.1 {
                                    selectedEvent = event
                                    showSelectedEventPopover = true
                                    return
                                }
                            }
                        }
                    }
            }
                
            Divider()
            
            ListPopoverButton_E(showSelectionList: $showSelectionList, selectedCategories: $selectedCategories, allCategories: allCategories)

            Divider()

            
        }
        .overlay {
            if filteredEvents.isEmpty {
                ContentUnavailableView {
                    Label("No events yet", systemImage: "chart.line.downtrend.xyaxis.circle.fill")
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
