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
    
    @State private var eventCategories = [String]() // filled in .onAppear, with inserting 'All'
    @State private var symptomNames = [String]() // filled in .onAppear, with inserting 'All'
    @State private var selectedSingleCategory: String?
    @State private var selectedSymptom: Symptom? // in order for Chart view @Query filtering to work dynamically, the selection needs to happen outside the Chart view
    @State private var selectedMedicine: Medicine?

    @State var startDisplayDate: Date = (Date().setDate(day: 1, month: 1, year: 2020) ?? .now).addingTimeInterval(-30*24*3600)
    @State var endDisplayDate: Date = Date().setDate(day: 1, month: 1, year: 2020) ?? .now

    var body: some View {
        List {
            Section {
                DiarySelectionSection(selectedDisplayTime: $selectedDisplayTime, startDisplayDate: $startDisplayDate, endDisplayDate: $endDisplayDate)
            }
            
            Section {
                
                HStack {

                    Button("", systemImage: "chevron.left") {}.padding(.trailing)
                    .onTapGesture { // required for two buttons in same hStack to work
                        startDisplayDate = startDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
                        endDisplayDate = endDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
                    }
                    
                    Text(startDisplayDate.formatted(date: .abbreviated, time: .omitted) + " - " + endDisplayDate.formatted(date: .abbreviated, time: .omitted)).font(.title).bold()
                    
                    Button("", systemImage: "chevron.right") {
                        startDisplayDate = startDisplayDate.addingTimeInterval(selectedDisplayTime.timeValue)
                        endDisplayDate = endDisplayDate.addingTimeInterval(selectedDisplayTime.timeValue)
                    }.padding(.leading)
                }
                VStack(alignment: .leading) {
                    Ratings_Medicines_ChartView(symptom: $selectedSymptom, symptoms: symptomsList, selectedMedicine: $selectedMedicine, medicines: medicinesList, from: startDisplayDate, to: endDisplayDate)
//                    ZStack {
////                        VStack {
//                            RatingsChartView(symptom: $selectedSymptom, symptoms: symptomsList, from: startDisplayDate, to: endDisplayDate)
//                            MedicinesChartView(selectedMedicine: $selectedMedicine, medicines: medicinesList, from: startDisplayDate, to: endDisplayDate)
////                        }
//                    }
                }
                VStack(alignment: .leading) {
                    EventsChartView(selectedCategory: $selectedSingleCategory, allCategories: eventCategories, from: startDisplayDate, to: endDisplayDate)
                }
            }
        }
        .onAppear {
            let allCategories = Set(events.compactMap { $0.category })
            eventCategories = Array(allCategories)
            eventCategories.insert(UserText.term("All"), at: 0)
            
            let allSymptoms = Set(symptomsList.compactMap { $0.name })
            symptomNames = Array(allSymptoms)
            symptomNames.insert(UserText.term("All"), at: 0)
            
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