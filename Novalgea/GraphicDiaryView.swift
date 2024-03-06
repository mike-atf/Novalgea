//
//  GraphicDiaryView.swift
//  Novalgea
//
//  Created by aDev on 29/02/2024.
//

import SwiftUI
import SwiftData
import OSLog

struct GraphicDiaryView: View {
    
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \DiaryEvent.date, order: .reverse) var events: [DiaryEvent]
        @Query (filter: #Predicate<Rating> { aRating in
        aRating.ratedSymptom != nil
    }) var symptomRatings: [Rating]
    @Query(filter: #Predicate<Symptom> {
        !$0.isSideEffect
    }, sort: \Symptom.name) var symptomsList: [Symptom]
    @Query(filter: #Predicate<Symptom> {
        $0.isSideEffect
    }, sort: \Symptom.name) var sideEffects: [Symptom]
    @Query(sort: \Medicine.name) var medicinesList: [Medicine]


    @State var categoriesDisplayed: [String]?
    @State var selectedDisplayTime: DisplayTimeOption = .month
    
    @State private var allEventCategories = [String]() // filled in .onAppear, with inserting 'All'
    @State private var symptomNames = [String]() // filled in .onAppear, with inserting 'All'
    @State private var selectedSingleCategory: String?
    
    // in order for Chart view @Query filtering to work dynamically selections needs to happen outside the Chart view
    @State private var selectedSymptoms: Set<Symptom>?
    @State private var selectedMedicines: Set<Medicine>?
    @State private var selectedEventCategories: Set<String>?

    @State var startDisplayDate: Date = (Date().setDate(day: 1, month: 1, year: 2020) ?? .now).addingTimeInterval(-30*24*3600)
    @State var endDisplayDate: Date = Date().setDate(day: 1, month: 1, year: 2020) ?? .now

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Section {
                    DiarySelectionSection(selectedDisplayTime: $selectedDisplayTime, startDisplayDate: $startDisplayDate, endDisplayDate: $endDisplayDate)
                }
                
                Section {
                    
                    HStack {
                        
                        Button("", systemImage: "chevron.left") {
                            startDisplayDate = startDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
                            endDisplayDate = endDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
                        }
                        Text(DatesManager.displayPeriodTerm(_for: selectedDisplayTime, start: startDisplayDate, end: endDisplayDate)).font(.title2).bold()
                        Button("", systemImage: "chevron.right") {
                            startDisplayDate = startDisplayDate.addingTimeInterval(selectedDisplayTime.timeValue)
                            endDisplayDate = endDisplayDate.addingTimeInterval(selectedDisplayTime.timeValue)
                        }
                    }
                    VStack(alignment: .leading) {
                        Ratings_Medicines_ChartView(selectedSymptoms: $selectedSymptoms, symptoms: symptomsList, selectedMedicines: $selectedMedicines, medicines: medicinesList, from: startDisplayDate, to: endDisplayDate)
                    }
                    .frame(height: geometry.size.height * 0.4)
                    VStack(alignment: .leading) {
                        EventsChartView(selectedCategories: $selectedEventCategories, allCategories: allEventCategories, from: startDisplayDate, to: endDisplayDate)
                    }
                }
            }
            .onAppear {
                let allCategories = Set(events.compactMap { $0.category })
                allEventCategories = Array(allCategories)
//                allEventCategories.insert(UserText.term("All"), at: 0)
                
                let allSymptoms = Set(symptomsList.compactMap { $0.name })
                symptomNames = Array(allSymptoms)
//                symptomNames.insert(UserText.term("All"), at: 0)
            }
            .padding(.horizontal)
        }
    }
    
    func back() {
        let newStart = startDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
        let newEnd = endDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
        startDisplayDate = newStart
        endDisplayDate = newEnd
    }
    
    func forward() {
        startDisplayDate = startDisplayDate.addingTimeInterval(selectedDisplayTime.timeValue)
        endDisplayDate = endDisplayDate.addingTimeInterval(selectedDisplayTime.timeValue)
    }
}

#Preview {
    GraphicDiaryView()
}
