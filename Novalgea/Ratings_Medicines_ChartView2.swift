//
//  Ratings_Medicines_ChartView2.swift
//  Novalgea
//
//  Created by aDev on 12/03/2024.
//

import SwiftUI
import SwiftData
import Charts
import OSLog

struct Ratings_Medicines_ChartView2: View {
    
    @Environment(\.modelContext) private var modelContext

    @Binding var selectedSymptoms: Set<Symptom>?
    @Binding var selectedMedicines: Set<Medicine>?

    @State var showSymptomList = false
    @State var showMedicinesList = false
    @State var chartYScaleLimit: Int

    var medicines: [Medicine]
    var allMedicines: [Medicine]
    
    var symptoms: [Symptom]
    var allSymptoms: [Symptom]

    var fromDate: Date
    var toDate: Date
    var displayTime: DisplayTimeOption

    // dynamic filtering of events - for this the symptom selection must happen outside this view, so the view is re-created when a selection is made
    // instead of .contains use .localizedStandardContains
    init(selectedSymptoms: Binding<Set<Symptom>?>, symptoms: [Symptom], selectedMedicines: Binding<Set<Medicine>?>, medicines: [Medicine],from: Date, to: Date, displayTime: DisplayTimeOption) {
        
        self.fromDate = from
        self.toDate = to
        
        self.allSymptoms = symptoms
        self.symptoms = selectedSymptoms.wrappedValue == nil ? symptoms : Array(selectedSymptoms.wrappedValue!)
        _selectedSymptoms = selectedSymptoms
        
        self.allMedicines = medicines
        self.medicines = selectedMedicines.wrappedValue == nil ? medicines : Array(selectedMedicines.wrappedValue!)
        _selectedMedicines = selectedMedicines
        
        self.displayTime = displayTime
        
        if displayTime == .quarter {
            chartYScaleLimit = 50
        } else if displayTime == .year {
            chartYScaleLimit = 100
        } else {
            chartYScaleLimit = 10
        }
    }

    
    var body: some View {
        
        VStack {

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
                                .foregroundColor(.secondary)
                        } else {
                            Text(UserText.term("Symptoms: ") + UserText.term("All"))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .popover(isPresented: $showSymptomList) {
                    VStack(alignment: .leading) {
                        ForEach(allSymptoms) { s0 in
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
                            }
                            Divider()

                        }
                    }
                    .presentationCompactAdaptation(.none)
                    .padding() // popover VStack padding
                }

                Spacer()
                
                //MARK: - medicines selection button
                Button {
                    showMedicinesList = true
                } label: {
                    HStack {
                        if selectedMedicines?.count ?? 0 > 0 {
                            Text(UserText.term("Meds: ") + "\(selectedMedicines!.count)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        } else {
                            Text(UserText.term("Meds: ") + UserText.term("All"))
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        Image(systemName: "line.3.horizontal.circle")
                    }
                }
                .popover(isPresented: $showMedicinesList) {
                    VStack(alignment: .leading) {
                        ForEach(allMedicines) { m0 in
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
                            }
                            Divider()

                        }
                    }
                    .presentationCompactAdaptation(.none)
                    .padding() // popover VStack padding

                }
            }
            Divider()
            
            //MARK: - combined chart
            VStack(alignment: .leading) {
                Text(UserText.term("Symptom VAS averages")).font(.title2).bold()
                Text(fromDate.formatted(.dateTime.day().month()) + " - " + toDate.formatted(date: .abbreviated, time: .omitted)).foregroundStyle(.secondary)
                    .padding(.bottom, -5)

                Chart {
                    
                    ForEach(symptoms) {
                        let average = $0.ratingAverage(from: fromDate, to: toDate) ?? 0
                        BarMark(x: .value("Symptoms", $0.name), y: .value("average VAS", average))
                            .foregroundStyle(by: .value("Symptoms", $0.name))
                            .annotation(position: .top) {
                                if average != 0.0 {
                                    Text(average, format: .number.precision(.fractionLength(1))).font(.system(size: 8))
                                }
                            }
                            .mask {RectangleMark() }
                    }
                    
                    
                }
                .chartYScale(domain: 0...10)
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 5))
                }
                .chartLegend(position: .top)
                .clipped()
                
                Text(UserText.term("Medication doses")).font(.title2).bold()
                Text(fromDate.formatted(.dateTime.day().month()) + " - " + toDate.formatted(date: .abbreviated, time: .omitted)).foregroundStyle(.secondary)
                    .padding(.bottom, -5)

                Chart {
                    ForEach(medicines) {
                        let dosesTaken = $0.dosesTaken(from: fromDate, to: toDate)
                        BarMark(x: .value("Meds", $0.name), y: .value("doses", dosesTaken))
                            .foregroundStyle(by: .value("Meds", $0.name))
                            .annotation(position: .bottom) {
                                if dosesTaken > 0 {
                                    Text(dosesTaken.formatted()).font(.system(size: 10))//.foregroundStyle(.white)
                                }
                            }
                            .mask { RectangleMark() }
                    }

                }
                .chartYScale(domain: 0...chartYScaleLimit)
                .chartLegend(position: .top)
                .clipped()

            }
        }
    }
}
