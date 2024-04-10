//
//  Ratings_Medicines_ChartView.swift
//  Novalgea
//
//  Created by aDev on 05/03/2024.
//

import SwiftUI
import SwiftData
import Charts
import OSLog

struct Ratings_Medicines_ChartView: View {
    
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Rating.date) var symptomRatings: [Rating]
    @Query(sort: \MedicineEvent.startDate) var completedMedEvents: [MedicineEvent] // with an end date set = prn med events or regular events that have ended
    @Query(sort: \MedicineEvent.startDate) var inCompleteMedEvents: [MedicineEvent] // without an end date set = prn med events or regular events that have ended

    @Binding var selectedSymptoms: Set<Symptom>?
    @Binding var selectedSideEffects: Set<Symptom>?
    @Binding var selectedMedicines: Set<Medicine>?
    @Binding var selectedDiaryEvent: DiaryEvent?
    @Binding var showRatingButton: Bool
    @Binding var showNewSymptomView: Bool
 
    @State var showSymptomList = false
    @State var showMedicinesList = false

    var medicines: [Medicine]
    var symptoms: [Symptom]
    var sideEffects: [Symptom]

    var fromDate: Date
    var toDate: Date
    
    private var filteredRatings: [Rating] { // will only be applied once selectedSymptoms != nil!
        
        guard selectedSymptoms != nil else { return symptomRatings }
        
        return symptomRatings.filter { rating in
            if selectedSymptoms!.contains(rating.ratedSymptom!) { return true }
            else { return false }
        }.sorted { $0.date < $1.date }
    }
    
    private var medEventsWithEnd: [MedicineEvent] { // will only be applied once selectedSymptoms != nil!
        
        guard selectedMedicines != nil else { return completedMedEvents }
        
        return completedMedEvents.filter { medEvent in
            if medEvent.endDate == nil { return false }
            else if medEvent.startDate > toDate { return false }
            else if medEvent.endDate! < fromDate { return false }
            else if selectedMedicines!.contains(medEvent.medicine!) { return true }
            else { return false }
        }
    }
    
    private var openEndedMedEvents: [MedicineEvent] { // will only be applied once selectedSymptoms != nil!
        
        guard selectedMedicines != nil else { return inCompleteMedEvents }
        
        return inCompleteMedEvents.filter { medEvent in
            if medEvent.endDate != nil { return false }
            else if selectedMedicines!.contains(medEvent.medicine!) { return true }
            else { return false }
        }
    }

    // dynamic filtering of events - for this the symptom selection must happen outside this view, so the view is re-created when a selection is made
    // instead of .contains use .localizedStandardContains
    init(selectedSymptoms: Binding<Set<Symptom>?>, symptoms: [Symptom], selectedSideEffects: Binding<Set<Symptom>?> , sideEffects: [Symptom], selectedMedicines: Binding<Set<Medicine>?>, medicines: [Medicine], selectedEvent: Binding<DiaryEvent?> ,from: Date, to: Date, displayTime: DisplayTimeOption, showRatingButton: Binding<Bool>, showNewSymptomView: Binding<Bool>) {
        
        // to include ratings before and after so line chart extends beyond chart boundaries
        var timeBeforeAndAfter: TimeInterval = 0
        switch displayTime {
        case .day:
            timeBeforeAndAfter = 24*3600
        case .week:
            timeBeforeAndAfter = 7*24*3600
        default:
            timeBeforeAndAfter = 0
        }
        let start = from.addingTimeInterval(-timeBeforeAndAfter)
        let end = to.addingTimeInterval(timeBeforeAndAfter)
        
        _symptomRatings = Query(filter: #Predicate<Rating> { aRating in
            aRating.ratedSymptom != nil &&
            aRating.date >= start &&
            aRating.date <= end
        }, sort: \Rating.date)

        _completedMedEvents = Query(filter: #Predicate<MedicineEvent> { medEvent in
            medEvent.medicine != nil
        }, sort: \MedicineEvent.startDate)
        
        _inCompleteMedEvents = Query(filter: #Predicate<MedicineEvent> { medEvent in
            medEvent.medicine != nil &&
            medEvent.endDate == nil
        }, sort: \MedicineEvent.startDate)

        
        self.fromDate = from
        self.toDate = to
        
        self.symptoms = symptoms
        _selectedSymptoms = selectedSymptoms
        
        self.sideEffects = sideEffects
        _selectedSideEffects = selectedSideEffects

        self.medicines = medicines
        _selectedMedicines = selectedMedicines
        
        _selectedDiaryEvent = selectedEvent
        
        _showRatingButton = showRatingButton
        _showNewSymptomView = showNewSymptomView
    }

    
    var body: some View {
        
        VStack(alignment: .leading) {
            //MARK: - header
            Divider()
            Text(UserText.term("VAS & medication")).font(.title2).bold()
            HStack {
                ListPopoverButton(showSymptomList: $showSymptomList, showNewSymptomView: $showNewSymptomView, selectedSymptoms: $selectedSymptoms, selectedSideEffects: $selectedSideEffects, symptoms: symptoms, sideEffects: sideEffects)
//                Spacer()
//                ListPopoverButton_M(showMedicinesList: $showMedicinesList, selectedMedicines: $selectedMedicines, medicines: medicines)
            }

            //MARK: - combined chart
            Chart {
                
                // 2 - above 1 : medicine events
                ForEach(medEventsWithEnd) {
                    RectangleMark(
                        xStart: .value("Start", $0.startDate),
                        xEnd: .value("End", $0.endDateForChart(chartEndDate: toDate)),
                        yStart: .value("", 0),
                        yEnd: .value("", 10)
                    )
                    .foregroundStyle(by: .value("Medicine", $0.medicine!.name))
                    .opacity(0.5)
                }
                
                ForEach(openEndedMedEvents) {
                    let _ = print($0.medicine!.name, $0.startDate, $0.endDateForChart(chartEndDate: toDate))
                    
                    RectangleMark(
                        xStart: .value("Start", $0.startDate),
                        xEnd: .value("End", $0.endDateForChart(chartEndDate: toDate)),
                        yStart: .value("", 0),
                        yEnd: .value("", 5)
                    )
                    .foregroundStyle(by: .value("Medicine", $0.medicine!.name))
                    .opacity(0.5)
                }
                
                
                // 1 -
                ForEach(filteredRatings) {
                    AreaMark(x: .value("Date", $0.date), y: .value("VAS", $0.vas))
                        .foregroundStyle(by: .value("Symptom", $0.ratedSymptom!.name))
                        .interpolationMethod(.monotone)
                        .opacity(0.4)
                    LineMark(x: .value("Date", $0.date), y: .value("VAS", $0.vas))
                        .foregroundStyle(by: .value("Symptom", $0.ratedSymptom!.name))
                        .interpolationMethod(.monotone)
                        .symbol(Circle())
                }
                
                // 3 - selected event line
                if selectedDiaryEvent != nil {
                    RuleMark(x: .value("", selectedDiaryEvent!.date))
                        .opacity(0.8)
                        .foregroundStyle(.gray)
                }
                
            }
            .chartPlotStyle { plotArea in
               plotArea
                   .frame(minHeight: 150)
                   .frame(maxHeight: 250)
            }
            .chartXScale(domain: fromDate...toDate)
            .chartYScale(domain: 0...10)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
            .clipped()
            .overlay {
                if filteredRatings.isEmpty && completedMedEvents.isEmpty && inCompleteMedEvents.isEmpty {
                    ContentUnavailableView {
                        Label(UserText.term("No records for this time period"), systemImage: "chart.line.uptrend.xyaxis.circle").imageScale(.medium).font(.body)
                    } description: {
                        //Text("Ratings and medication events will be plotted here.").font(.footnote)
                    }
                }
            }
            .transition(.move(edge: .leading))
            .frame(minHeight: 150)
            
            Divider()
            
            HStack {
                Spacer()
                SmallRatingButton(showRatingButton: $showRatingButton)
                    .frame(width: 45, height: 45)
                Spacer()

            }
            
            Divider()

        }
    }
}

//#Preview {
//    Ratings_Medicines_ChartView(selectedSymptoms: .constant(Set<Symptom>(_immutableCocoaSet: Symptom.preview)), symptoms: [Symptom.preview], selectedMedicine: .constant(Medicine.preview), medicines: [Medicine.preview], from: Date(), to: Date().addingTimeInterval(-30*24*3600))
//}
