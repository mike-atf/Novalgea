//
//  MedicinesChartView.swift
//  Novalgea
//
//  Created by aDev on 05/03/2024.
//


import SwiftUI
import SwiftData
import Charts
import OSLog

struct MedicinesChartView: View {
    
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \PRNMedEvent.startDate) var medEvents: [PRNMedEvent]

    @Binding var selectedMedicine: Medicine?
    var medicines: [Medicine]

    var fromDate: Date
    var toDate: Date
    
    // dynamic filtering of events - for this the symptom selection must happen outside this view, so the view is re-created when a selection is made
    // instead of .contains use .localizedStandardContains
    
    init(selectedMedicine: Binding<Medicine?>, medicines: [Medicine], from: Date, to: Date) {
        
        if let theMedicine = selectedMedicine.wrappedValue {
            let name = theMedicine.name
            let predicate = #Predicate<PRNMedEvent> {
                ($0.medicine?.name.localizedStandardContains(name) == true) &&
                $0.startDate >= from &&
                $0.startDate <= to
            }
            _medEvents = Query(filter: predicate, sort:\PRNMedEvent.startDate)
        } else {
            _medEvents = Query(filter: #Predicate<PRNMedEvent> { medEvent in
                medEvent.medicine != nil &&
                medEvent.startDate >= from &&
                medEvent.startDate <= to
            }, sort:\PRNMedEvent.startDate)
        }
        
        self.fromDate = from
        self.toDate = to
        self.medicines = medicines
        
        _selectedMedicine = selectedMedicine
        
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Menu {
                        ForEach(medicines, id: \.self) {
                            medicine in
                            
                            HStack {
                                
                                Button(action: {
                                    if selectedMedicine == medicine {
                                        selectedMedicine = nil
                                    } else {
                                        selectedMedicine = medicine
                                    }
                                }, label: {
                                    HStack {
                                        Text(medicine.name)
                                        if selectedMedicine == medicine {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                })
                            }
                        }
                        
                    } label: {
                        HStack {
                            Text(UserText.term("Show: ") + (selectedMedicine?.name ?? "All"))
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                
                Chart(medEvents) { event in
                    RectangleMark(
                        xStart: .value("Start", event.startDate),
                        xEnd: .value("End", event.endDate),
                        yStart: .value("", 0),
                        yEnd: .value("", 10)
                    )
                    .foregroundStyle(by: .value("Category", event.medicine!.name))
                }
                .chartLegend(position: .topTrailing)
                .chartXScale(domain: fromDate...toDate)
                .chartYScale(domain: 0...10)
                .opacity(0.25)
            }
        }
    }
}

//#Preview {
//    RatingsChartView(from: Date().addingTimeInterval(-30*24*3600), to: .now)
//}
