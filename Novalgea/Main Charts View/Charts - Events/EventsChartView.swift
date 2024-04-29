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
    @Binding var selectedEventIndex: Int?

    @State var showSelectionList = false
    @State var rawSelectedDate: Date?
    @State var showSelectedEventPopover = false
//    @State var selectedEventIndex: Int?
    
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
        
        return eventsInScope.sorted { de0, de1 in
            if de0.date < de1.date { return true }
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
    
    init(selectedCategories: Binding<Set<EventCategory>?>, showNewCategoryView: Binding<Bool> ,selectedDiaryEvent: Binding<DiaryEvent?>, selectedEventIndex: Binding<Int?> ,allCategories: [EventCategory], from: Date, to: Date) {
        
        _events = Query(filter: #Predicate<DiaryEvent> {
            $0.date >= from &&
            $0.date <= to
        }, sort:\DiaryEvent.date)

        _selectedCategories = selectedCategories
        _selectedEvent = selectedDiaryEvent
        _showNewCategoryView = showNewCategoryView
        _selectedEventIndex = selectedEventIndex
        
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
                        .foregroundStyle(event.category?.color() ?? Color.primary)
                        .symbolSize(400)
                        .annotation(position: .overlay, alignment: .center, spacing: 0) {
                            Text(event.category!.symbol).font(.footnote)
                        }
                }
                else {
                    RectangleMark(
                        xStart: .value("Start", event.date),
                        xEnd: .value("End", event.chartDisplayEndDate(defaultDuration: 1*3600)),
                        yStart: .value("", categoryChartLines[event.category!.name] ?? 0),
                        yEnd: .value("", categoryChartLines[event.category!.name]!+1)
                    )
                    .foregroundStyle(event.category?.color() ?? Color.primary)
//                    .foregroundStyle(by: .value("Category", event.category!.name))
                    .annotation(position: .overlay, alignment: .center, spacing: 0) {
                        Text(event.category!.symbol).font(.footnote)
//                        Text(verbatim: String(event.category!.name.first!))
//                            .font(.caption).bold()
//                                    .foregroundStyle(by: .value("Category", event.category!.name))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))

                }
                
            }
            .chartPlotStyle { plotArea in
               plotArea
                   .frame(minHeight: 100)
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
                        
                        let verticalRange: ClosedRange = (value.1 - 1 ... value.1)
                        //Check if value is included in the data from the chart
                        for event in filteredEvents {
                            let eventDuration = event.endDate == nil ? eventSelectionTimeAdjustment : event.endDate!.timeIntervalSince(event.date)
                            if (event.date.addingTimeInterval(-eventSelectionTimeAdjustment) ... event.date.addingTimeInterval(eventDuration)).contains(value.0) {
                                if verticalRange.contains(categoryChartLines[event.category!.name] ?? 0) {
                                    selectedEvent = event
                                    showSelectedEventPopover = true
                                    selectedEventIndex = events.firstIndex(of: selectedEvent!)
                                    return
                                }
                            }
                        }
                    }
            }
            .transition(.move(edge: .leading))
            
            if selectedEvent != nil {
                withAnimation {
                    EventDescriptionView(selectedEvent: $selectedEvent, eventIndex: $selectedEventIndex, allEventsInRange: filteredEvents)
                }
            }
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

#Preview {
    EventsChartView(selectedCategories: .constant([EventCategory.preview]), showNewCategoryView: .constant(false), selectedDiaryEvent: .constant(DiaryEvent.preview), selectedEventIndex: .constant(0), allCategories: [EventCategory.preview], from: .now.addingTimeInterval(-30*24*3600), to: .now)
}
