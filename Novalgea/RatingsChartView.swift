//
//  RatingsChartView.swift
//  Novalgea
//
//  Created by aDev on 02/03/2024.
//

import SwiftUI
import SwiftData
import Charts
import OSLog

struct RatingsChartView: View {
    
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Rating.date) var symptomRatings: [Rating]
    @Query(sort: \DiaryEvent.date) var events: [DiaryEvent]
    @Query(sort: \PRNMedEvent.startDate) var medEvents: [PRNMedEvent]

    @Binding var selectedSymptom: Symptom?
    var symptoms: [Symptom]

    var fromDate: Date
    var toDate: Date
    
    // dynamic filtering of events - for this the symptom selection must happen outside this view, so the view is re-created when a selection is made
    // instead of .contains use .localizedStandardContains
    
    init(symptom: Binding<Symptom?>, symptoms: [Symptom], from: Date, to: Date) {
        
        if let theSymptom = symptom.wrappedValue {
            let name = theSymptom.name
            let predicate = #Predicate<Rating> {
                ($0.ratedSymptom?.name.localizedStandardContains(name) == true) &&
                $0.date >= from &&
                $0.date <= to
            }
            _symptomRatings = Query(filter: predicate, sort:\Rating.date, order: .reverse)
        } else {
            _symptomRatings = Query(filter: #Predicate<Rating> { aRating in
                aRating.ratedSymptom != nil &&
                aRating.date >= from &&
                aRating.date <= to
            }, sort:\Rating.date, order: .reverse)
        }
        
        self.fromDate = from
        self.toDate = to
        self.symptoms = symptoms
        
        _selectedSymptom = symptom
        
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Menu {
                    ForEach(symptoms, id: \.self) {
                        symptom in
                        
                        HStack {
                            
                            Button(action: {
                                if selectedSymptom == symptom {
                                    selectedSymptom = nil
                                } else {
                                    selectedSymptom = symptom
                                }
                            }, label: {
                                HStack {
                                    Text(symptom.name)
                                    if selectedSymptom == symptom {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            })
                        }
                    }
                    
                } label: {
                    HStack {
                        Text(UserText.term("Show: ") + (selectedSymptom?.name ?? "All"))
                        Image(systemName: "ellipsis.circle")
                    }
                }
                
                Chart(symptomRatings) { rating in
                    AreaMark(x: .value("Date", rating.date), y: .value("VAS", rating.vas))
                        .foregroundStyle(by: .value("Symptom", rating.ratedSymptom!.name))
                        .interpolationMethod(.linear)
                        .opacity(0.25)
                    LineMark(x: .value("Date", rating.date), y: .value("VAS", rating.vas))
                        .foregroundStyle(by: .value("Symptom", rating.ratedSymptom!.name))
                        .interpolationMethod(.linear)
                }
                .chartXScale(domain: fromDate...toDate)
                .chartYScale(domain: 0...10)
            }
        }
    }
}

//#Preview {
//    RatingsChartView(from: Date().addingTimeInterval(-30*24*3600), to: .now)
//}
