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
    
    @State var showSelectionList = false
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
    
    init(selectedCategories: Binding<Set<String>?>, allCategories: [String], from: Date, to: Date) {
        
        _events = Query(filter: #Predicate<DiaryEvent> {
            $0.date >= from &&
            $0.date <= to
        }, sort:\DiaryEvent.date)

        _selectedCategories = selectedCategories
        self.fromDate = from
        self.toDate = to
        self.allCategories = allCategories        
    }


    var body: some View {
        
        ZStack {
            VStack(alignment: .leading) {
                
                HStack {
                    //MARK: - category selection button
                    Button {
                        showSelectionList = true
                    } label: {
                        HStack {
                            Image(systemName: "line.3.horizontal.circle")
                            if selectedCategories?.count ?? 0 > 0 {
                                Text(UserText.term("Categories: ") + "\(selectedCategories!.count)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            } else {
                                Text(UserText.term("Categories: ") + UserText.term("All"))
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(5)
                        .background {
                            RoundedRectangle(cornerRadius:6)
                                .foregroundColor(.white)
                                .opacity(0.6)
                        }
                    }
                    .popover(isPresented: $showSelectionList) {
                        
                        VStack(alignment: .leading) {
                            
                            ForEach(allCategories.indices, id: \.self) { index in
                                Button {
                                    if selectedCategories == nil {
                                        selectedCategories = Set<String>()
                                        selectedCategories!.insert(allCategories[index])
                                    }
                                    else if selectedCategories!.contains(allCategories[index]) {
                                        selectedCategories!.remove(allCategories[index])
                                    } else {
                                        selectedCategories!.insert(allCategories[index])
                                    }
                                } label: {
                                    HStack {
                                        if (selectedCategories == nil) {
                                            Image(systemName: "circle")
                                        } else if selectedCategories!.contains(allCategories[index]) {
                                            Image(systemName: "checkmark.circle.fill").symbolRenderingMode(.multicolor)
                                        } else {
                                            Image(systemName: "circle")
                                        }
                                        Text(allCategories[index]).font(.footnote)
                                    }
                                    .foregroundStyle(.black)
                                }
                                Divider()
                                
                            }
                        }
                        .padding()
                        .presentationCompactAdaptation(.none)
                    }
                    
                }

                //MARK: - chart
                Chart(filteredEvents) { event in
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
