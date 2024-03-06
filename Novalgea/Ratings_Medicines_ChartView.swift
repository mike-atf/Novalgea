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

    @Binding var selectedSymptoms: Set<Symptom>?
    @Binding var selectedMedicines: Set<Medicine>?

    @State var showSymptomList = false
    @State var showMedicinesList = false
    
    var medicines: [Medicine]
    var symptoms: [Symptom]

    var fromDate: Date
    var toDate: Date
    
    private var filteredRatings: [Rating] {
        
        guard selectedSymptoms != nil else { return symptomRatings }
        
        return symptomRatings.filter { rating in
            if selectedSymptoms!.contains(rating.ratedSymptom!) { return true }
            else { return false }
        }
    }
    
    private var filteredMedicines: [PRNMedEvent] {
        
        guard selectedMedicines != nil else { return medEvents }
        
        return medEvents.filter { medEvent in
            if selectedMedicines!.contains(medEvent.medicine!) { return true }
            else { return false }
        }
    }

    
    // dynamic filtering of events - for this the symptom selection must happen outside this view, so the view is re-created when a selection is made
    // instead of .contains use .localizedStandardContains
    init(selectedSymptoms: Binding<Set<Symptom>?>, symptoms: [Symptom], selectedMedicines: Binding<Set<Medicine>?>, medicines: [Medicine], from: Date, to: Date) {
        
        _symptomRatings = Query(filter: #Predicate<Rating> { aRating in
            aRating.ratedSymptom != nil &&
            aRating.date >= from &&
            aRating.date <= to
        }, sort:\Rating.date, order: .reverse)
        

        _medEvents = Query(filter: #Predicate<PRNMedEvent> { medEvent in
            medEvent.medicine != nil &&
            medEvent.startDate >= from &&
            medEvent.startDate <= to
        }, sort:\PRNMedEvent.startDate)
        
        self.fromDate = from
        self.toDate = to
        
        self.symptoms = symptoms
        _selectedSymptoms = selectedSymptoms
        
        self.medicines = medicines
        _selectedMedicines = selectedMedicines

        
    }

    
    var body: some View {
        
        ZStack(alignment: .top) {
            //MARK: - combined chart
            
            Chart {
                // 1 -
                ForEach(filteredRatings) {
                    AreaMark(x: .value("Date", $0.date), y: .value("VAS", $0.vas))
                        .foregroundStyle(by: .value("Symptom", $0.ratedSymptom!.name))
                        .interpolationMethod(.linear)
                        .opacity(0.25)
                    LineMark(x: .value("Date", $0.date), y: .value("VAS", $0.vas))
                        .foregroundStyle(by: .value("Symptom", $0.ratedSymptom!.name))
                        .interpolationMethod(.linear)
                }

                // 2 - above 1 : medicine events
                ForEach(filteredMedicines) {
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
                //MARK: - symptom selection button
                Button {
                    showSymptomList = true
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.circle")
                        if selectedSymptoms?.count ?? 0 > 0 {
                            Text(UserText.term("Symptoms: ") + "\(selectedSymptoms!.count)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        } else {
                            Text(UserText.term("Symptoms: ") + UserText.term("All"))
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
                .popover(isPresented: $showSymptomList) {
                    VStack(alignment: .leading) {
                        ForEach(symptoms) { s0 in
                            Button {
                                if selectedSymptoms == nil {
                                    selectedSymptoms = Set<Symptom>()
                                    selectedSymptoms!.insert(s0)
                                }
                                else if selectedSymptoms!.contains(s0) {
                                    selectedSymptoms!.remove(s0)
                                } else {
                                    selectedSymptoms!.insert(s0)
                                }
                            } label: {
                                HStack {
                                    if (selectedSymptoms == nil) {
                                        Image(systemName: "circle")
                                    } else if selectedSymptoms!.contains(s0) {
                                        Image(systemName: "checkmark.circle.fill").symbolRenderingMode(.multicolor)
                                    } else {
                                        Image(systemName: "circle")
                                    }
                                    Text(s0.name).font(.footnote)
                                }
                                .foregroundStyle(.black)
                            }
                            Divider()

                        }
                    }
                    .padding()
                    .presentationCompactAdaptation(.none)
                }

                Spacer()
                
                //MARK: - medicines selection button
                Button {
                    showMedicinesList = true
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.circle")
                        if selectedMedicines?.count ?? 0 > 0 {
                            Text(UserText.term("Meds: ") + "\(selectedMedicines!.count)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        } else {
                            Text(UserText.term("Meds: ") + UserText.term("All"))
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
                .popover(isPresented: $showMedicinesList) {
                    VStack(alignment: .leading) {
                        ForEach(medicines) { m0 in
                            Button {
                                if selectedMedicines == nil {
                                    selectedMedicines = Set<Medicine>()
                                    selectedMedicines!.insert(m0)
                                }
                                else if selectedMedicines!.contains(m0) {
                                    selectedMedicines!.remove(m0)
                                } else {
                                    selectedMedicines!.insert(m0)
                                }
                            } label: {
                                HStack {
                                    if (selectedMedicines == nil) {
                                        Image(systemName: "circle")
                                    } else if selectedMedicines!.contains(m0) {
                                        Image(systemName: "checkmark.circle.fill").symbolRenderingMode(.multicolor)
                                    } else {
                                        Image(systemName: "circle")
                                    }
                                    Text(m0.name).font(.footnote)
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
            .padding()
        }

    }
}

//#Preview {
//    Ratings_Medicines_ChartView(selectedSymptoms: .constant(Set<Symptom>(_immutableCocoaSet: Symptom.preview)), symptoms: [Symptom.preview], selectedMedicine: .constant(Medicine.preview), medicines: [Medicine.preview], from: Date(), to: Date().addingTimeInterval(-30*24*3600))
//}
