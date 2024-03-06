//
//  Ratings_Medicines_ChartView.swift
//  Novalgea
//
//  Created by aDev on 05/03/2024.
//

import SwiftUI
import SwiftData
import Charts

struct Ratings_Medicines_ChartView: View {
    
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Rating.date) var symptomRatings: [Rating]
    @Query(sort: \PRNMedEvent.startDate) var medEvents: [PRNMedEvent]

    @Binding var selectedMedicine: Medicine?
    var medicines: [Medicine]

    @Binding var selectedSymptom: Symptom?
    var symptoms: [Symptom]

    var fromDate: Date
    var toDate: Date
    
    // dynamic filtering of events - for this the symptom selection must happen outside this view, so the view is re-created when a selection is made
    // instead of .contains use .localizedStandardContains
    
    init(symptom: Binding<Symptom?>, symptoms: [Symptom], selectedMedicine: Binding<Medicine?>, medicines: [Medicine], from: Date, to: Date) {
        
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
        
        self.symptoms = symptoms
        _selectedSymptom = symptom
        
        self.medicines = medicines
        _selectedMedicine = selectedMedicine

        
    }


    
    var body: some View {
        
        ZStack(alignment: .top) {
            // combined chart
            Chart {
                // 2 - above 1: Symptoms ratings
                ForEach(symptomRatings) {
                    AreaMark(x: .value("Date", $0.date), y: .value("VAS", $0.vas))
                        .foregroundStyle(by: .value("Symptom", $0.ratedSymptom!.name))
                        .interpolationMethod(.linear)
                        .opacity(0.25)
                    LineMark(x: .value("Date", $0.date), y: .value("VAS", $0.vas))
                        .foregroundStyle(by: .value("Symptom", $0.ratedSymptom!.name))
                        .interpolationMethod(.linear)
                }

                // 1 - medicine events
                ForEach(medEvents) {
                    RectangleMark(
                        xStart: .value("Start", $0.startDate),
                        xEnd: .value("End", $0.endDate),
                        yStart: .value("", 0),
                        yEnd: .value("", 10)
                    )
                    .foregroundStyle(by: .value("Medicine", $0.medicine!.name))
                    .opacity(0.3)
                }
                
            }
            .chartXScale(domain: fromDate...toDate)
            .chartYScale(domain: 0...10)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
            
            HStack {
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
                        Image(systemName: "line.3.horizontal.circle")
                        if let name = selectedSymptom?.name {
                            Text(name)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        } else {
                            Text(UserText.term("Symptoms: ") + (selectedSymptom?.name ?? "All"))
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
                        if let name = selectedMedicine?.name {
                            Text(name)
                                .font(.footnote)
                                .foregroundColor(.gray)
                        } else {
                            Text(UserText.term("Meds: ") + (selectedMedicine?.name ?? "All"))
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        Image(systemName: "line.3.horizontal.circle")
                    }
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundColor(.white)
                            .opacity(0.6)
                    }

                }
            }
            .padding()
        }

    }
}

#Preview {
    Ratings_Medicines_ChartView(symptom: .constant(Symptom.preview), symptoms: [Symptom.preview], selectedMedicine: .constant(Medicine.preview), medicines: [Medicine.preview], from: Date(), to: Date().addingTimeInterval(-30*24*3600))
}
