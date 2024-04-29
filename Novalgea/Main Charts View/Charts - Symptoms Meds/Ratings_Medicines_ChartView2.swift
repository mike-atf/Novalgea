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
    @Binding var selectedSideEffects: Set<Symptom>?
    @Binding var selectedMedicines: Set<Medicine>?
    @Binding var showRatingButton: Bool
    @Binding var showNewSymptomView: Bool
    @Binding var showSideEffects: Bool

    @State var showSymptomList = false
    @State var showMedicinesList = false
    @State var chartYScaleLimit: Int

    var medicinesPlotted: [Medicine]
    var allMedicines: [Medicine]
    
    var symptomsPlotted: [Symptom]
    var allSymptoms: [Symptom]
    var sideEffectsPlotted: [Symptom]
    var allSideEffects: [Symptom]

    var fromDate: Date
    var toDate: Date
    var displayTime: DisplayTimeOption

    // dynamic filtering of events - for this the symptom selection must happen outside this view, so the view is re-created when a selection is made
    // instead of .contains use .localizedStandardContains
    init(selectedSymptoms: Binding<Set<Symptom>?>, symptoms: [Symptom], selectedSideEffects: Binding<Set<Symptom>?>, sideEffects: [Symptom],  selectedMedicines: Binding<Set<Medicine>?>, medicines: [Medicine], from: Date, to: Date, displayTime: DisplayTimeOption, showRatingButton: Binding<Bool>, showNewSymptomView: Binding<Bool>, showSideEffects: Binding<Bool>) {
        
        self.fromDate = from
        self.toDate = to
        
        self.allSymptoms = symptoms
        self.symptomsPlotted = selectedSymptoms.wrappedValue == nil ? symptoms : Array(selectedSymptoms.wrappedValue!)
        _selectedSymptoms = selectedSymptoms
        
        self.allSideEffects = sideEffects
        self.sideEffectsPlotted = selectedSideEffects.wrappedValue == nil ? sideEffects : Array(selectedSideEffects.wrappedValue!)
        _selectedSideEffects = selectedSideEffects

        
        self.allMedicines = medicines
        self.medicinesPlotted = selectedMedicines.wrappedValue == nil ? medicines : Array(selectedMedicines.wrappedValue!)
        _selectedMedicines = selectedMedicines
        
        self.displayTime = displayTime
        
        _showRatingButton = showRatingButton
        _showNewSymptomView = showNewSymptomView
        _showSideEffects = showSideEffects

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
            Divider()
            
            //MARK: - combined chart
            VStack(alignment: .leading) {
                Text(UserText.term("Symptom VAS averages")).font(.title2).bold()
                HStack {
                    ListPopoverButton(showSymptomList: $showSymptomList, showNewSymptomView: $showNewSymptomView, selectedSymptoms: $selectedSymptoms, symptoms: allSymptoms)
                    Spacer()
                    Text(fromDate.formatted(.dateTime.day().month()) + " - " + toDate.formatted(date: .abbreviated, time: .omitted)).foregroundStyle(.secondary)
                        .font(.footnote)
                }
                                
                Chart {
                    if showSideEffects {
                        ForEach(sideEffectsPlotted) {
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
                    
                    ForEach(symptomsPlotted) {
                        let average = $0.ratingAverage(from: fromDate, to: toDate) ?? 0
                        BarMark(x: .value("Symptoms", $0.name), y: .value("average VAS", average))
                            .foregroundStyle(by: .value("Symptoms", $0.name))
                            .annotation(position: .top) {
                                if average != 0.0 {
                                    Text(average, format: .number.precision(.fractionLength(1))).font(.footnote) //.system(size: 8)
                                }
                            }
                            .mask {RectangleMark() }
                    }
                }
                .chartPlotStyle { plotArea in
                   plotArea
                       .frame(minHeight: 150)
                       .frame(maxHeight: 300)
                }
                .chartYScale(domain: 0...10)
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 5))
                }
                .clipped()
                .transition(.move(edge: .leading))
                .padding(.bottom)
                
                Divider()

                HStack {
                    Spacer()
                    //MARK: - small ratings button
                    SmallRatingButton(showRatingButton: $showRatingButton)
                        .frame(width: 40, height: 40)

                    Spacer()
                }
                
                Divider()
                
                Text(UserText.term("Medication doses")).font(.title2).bold()
                
                HStack{
                     //MARK: - medicines selection button
                    ListPopoverButton_M(showMedicinesList: $showMedicinesList, selectedMedicines: $selectedMedicines, medicines: medicinesPlotted, iconPosition: .leading)
                    Spacer()
                    Text(fromDate.formatted(.dateTime.day().month()) + " - " + toDate.formatted(date: .abbreviated, time: .omitted)).foregroundStyle(.secondary)
                        .padding(.bottom, -5).font(.footnote)
                }
                
                Divider()
                
                Chart {
                    ForEach(medicinesPlotted) {
                        let dosesTaken = $0.dosesTaken(from: fromDate, to: toDate)
                        BarMark(x: .value("Meds", $0.name), y: .value("doses", dosesTaken))
                            .foregroundStyle(by: .value("Meds", $0.name))
                            .annotation(position: .top) {
                                if dosesTaken > 0 {
                                    Text(dosesTaken.formatted()).font(.footnote)
                                }
                            }
                            .mask { RectangleMark() }
                    }

                }
                .chartPlotStyle { plotArea in
                   plotArea
                       .frame(minHeight: 150)
                       .frame(maxHeight: 300)
                }
                .chartYScale(domain: 0...chartYScaleLimit)
                .clipped()
                .padding(.bottom)
                
                Divider()

            }
        }
    }
}
