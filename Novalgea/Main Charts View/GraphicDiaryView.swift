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
    @State private var selectedDiaryEvent: DiaryEvent?

    @State var startDisplayDate: Date = DatesManager.monthStartAndEnd(ofDate: .now).first! //(Date().setDate(day: 1, month: 1, year: 2020) ?? .now).addingTimeInterval(-30*24*3600)
    @State var endDisplayDate: Date = DatesManager.monthStartAndEnd(ofDate: .now).last! // Date().setDate(day: 1, month: 1, year: 2020) ?? .now
    @State var dragOffset = CGSizeZero
    @State var showRatingButton = false
    @State var selectedVAS: Double?

    var body: some View {
        GeometryReader { geometry in
            VStack {
                //MARK: - Date selector
                Section {
                    DiarySelectionSection(selectedDisplayTime: $selectedDisplayTime, startDisplayDate: $startDisplayDate, endDisplayDate: $endDisplayDate)
                    HStack {
                        Button("", systemImage: "chevron.left") {
                            withAnimation {
                                stepDisplayTime(option: .backwards)
//                                startDisplayDate = startDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
//                                endDisplayDate = endDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
                            }
                        }
                        Text(DatesManager.displayPeriodTerm(_for: selectedDisplayTime, start: startDisplayDate, end: endDisplayDate)).font(.title2).bold()
                        Button("", systemImage: "chevron.right") {
                            withAnimation {
                                stepDisplayTime(option: .forwards)
//                                startDisplayDate = startDisplayDate.addingTimeInterval(selectedDisplayTime.timeValue)
//                                endDisplayDate = endDisplayDate.addingTimeInterval(selectedDisplayTime.timeValue)
                            }
                        }
                    }
                    .padding(.bottom, -5)
                }
                    ScrollView {
                        VStack(alignment: .leading) {
                            //MARK: - Ratings and Med event charts
                            if selectedDisplayTime == DisplayTimeOption.quarter || selectedDisplayTime == DisplayTimeOption.year {
                                Ratings_Medicines_ChartView2(selectedSymptoms: $selectedSymptoms, symptoms: symptomsList, selectedMedicines: $selectedMedicines, medicines: medicinesList, from: startDisplayDate, to: endDisplayDate, displayTime: selectedDisplayTime)
                                    .frame(height: geometry.size.height * 0.6)
                                
                                if showRatingButton {
                                        Divider()
                                    RatingButton(showView: $showRatingButton, vas: $selectedVAS)
                                            .frame(height: min(geometry.size.height/4, geometry.size.width))
                                    Divider()
                                }
                            } else {
                               Ratings_Medicines_ChartView(selectedSymptoms: $selectedSymptoms, symptoms: symptomsList, selectedMedicines: $selectedMedicines, medicines: medicinesList, selectedEvent: $selectedDiaryEvent, from: startDisplayDate, to: endDisplayDate, displayTime: selectedDisplayTime, showRatingButton: $showRatingButton)
                                    .frame(height: geometry.size.height * 0.5)
                                
                                if showRatingButton {
                                        Divider()
                                    RatingButton(showView: $showRatingButton, vas: $selectedVAS)
                                            .frame(height: min(geometry.size.height/4, geometry.size.width))
                                    Divider()
                                }
                            }
                        }
                        .gesture(
                            
                            //MARK: - Swiping Gesture
                            // edge swiping gesture
                            DragGesture(minimumDistance: 50)
                                .onChanged({ value in
                                    dragOffset = value.translation
                                })
                                .onEnded({ _ in
                                    selectedDiaryEvent = nil
                                    if dragOffset.width > 0 {
                                        withAnimation {
                                            startDisplayDate = startDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
                                            endDisplayDate = endDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
                                        }
                                    } else if dragOffset.width < 0 {
                                        withAnimation {
                                            startDisplayDate = startDisplayDate.addingTimeInterval(selectedDisplayTime.timeValue)
                                            endDisplayDate = endDisplayDate.addingTimeInterval(selectedDisplayTime.timeValue)
                                        }
                                    }
                                })
                            
                        )
                        VStack(alignment: .leading) {
                            //MARK: - Events Charts
                            if selectedDisplayTime == DisplayTimeOption.quarter || selectedDisplayTime == DisplayTimeOption.year {
                                EventsChartView2(selectedCategories: $selectedEventCategories, allCategories: allEventCategories, from: startDisplayDate, to: endDisplayDate)
                                    .frame(height: geometry.size.height * 0.5)
                                
                            }
                            else {
                                EventsChartView(selectedCategories: $selectedEventCategories, selectedDiaryEvent: $selectedDiaryEvent, allCategories: allEventCategories, from: startDisplayDate, to: endDisplayDate)
                                    .frame(height: geometry.size.height * 0.3)
                                
                            }
                        }
                        //MARK: - Selected Diary event view
                        if selectedDiaryEvent != nil {
                            withAnimation {
                                VStack(alignment: .leading) {
                                    Divider()
                                    HStack {
                                        Text("\(selectedDiaryEvent!.date.formatted())").font(.subheadline).bold()
                                        Button {
                                            selectedDiaryEvent = nil
                                        } label: {
                                            Image(systemName: "x.circle.fill")
                                        }
                                        
                                    }
                                    Text(selectedDiaryEvent!.notes).font(.footnote)
                                        .lineLimit(nil)
                                }
                            }
                        }
                    }
                    .scrollDisabled(showRatingButton)
                
            }
            .onAppear {
                let allCategories = Set(events.compactMap { $0.category })
                allEventCategories = Array(allCategories)
                
                let allSymptoms = Set(symptomsList.compactMap { $0.name })
                symptomNames = Array(allSymptoms)
//                cleanRatingDuplicates()
            }
            .padding(.horizontal)
        }
    }
    
    private func stepDisplayTime(option: ChangeDisplayTime) {
        
        let step = option == .backwards ? -1 : 1
        
        switch selectedDisplayTime {
        case .day:
            startDisplayDate = DatesManager.startOfDay(from: startDisplayDate, _by: step)
            endDisplayDate = startDisplayDate.addingTimeInterval(24*3600-1)
        case .week:
            startDisplayDate = DatesManager.startOfWeek(from: startDisplayDate, _by: step)
            endDisplayDate = DatesManager.startOfWeek(from: startDisplayDate, _by: 1).addingTimeInterval(-1)
        case .month:
            startDisplayDate = DatesManager.startOfMonth(from: startDisplayDate, _by: step)
            endDisplayDate = DatesManager.startOfMonth(from: startDisplayDate, _by: 1).addingTimeInterval(-1)
        case .quarter:
            startDisplayDate = DatesManager.startOfQuarter(from: startDisplayDate, _by: step)
            endDisplayDate = DatesManager.startOfQuarter(from: startDisplayDate, _by: 1).addingTimeInterval(-1)
        case .year:
            startDisplayDate = DatesManager.startOfYear(from: startDisplayDate, _by: step)
            endDisplayDate = DatesManager.startOfYear(from: startDisplayDate, _by: 1).addingTimeInterval(-1)
        }
        
        Logger().info("new start \(startDisplayDate.formatted())")
        Logger().info("new end \(endDisplayDate.formatted())")
        Logger().info("=============")
   }
        
//    func cleanRatingDuplicates() {
//        
//        let fetchDescriptorS = FetchDescriptor<Rating>(sortBy: [SortDescriptor(\Rating.date)])
//        if let existingSymptoms = try? modelContext.fetch(fetchDescriptorS) {
//            var ratingsToDelete = [Rating]()
//            for i in 1..<existingSymptoms.count {
//                let current = existingSymptoms[i]
//                let previous = existingSymptoms[i-1]
//                
//                if current.vas == previous.vas {
//                    if (current.ratedSymptom?.name ?? "none") == (previous.ratedSymptom?.name ?? "none") {
//                        if current.date.timeIntervalSince(previous.date) < 60 {
//                            ratingsToDelete.append(current)
//                        }
//                    }
//                }
//                
//                for rating in ratingsToDelete {
//                    modelContext.delete(rating)
//                }
//            }
//        }
        
//    }
}

#Preview {
    GraphicDiaryView()
}
