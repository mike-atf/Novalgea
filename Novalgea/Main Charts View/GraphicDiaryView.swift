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
    }, sort: \Symptom.name) var allSymptoms: [Symptom]
    @Query(filter: #Predicate<Symptom> {
        $0.isSideEffect
    }, sort: \Symptom.name) var allSideEffects: [Symptom]
    @Query(sort: \Medicine.name) var allMedicines: [Medicine]
    @Query(sort: \EventCategory.name) var allEventCategories: [EventCategory]

    @State var categoriesDisplayed: [String]?
    @State var selectedDisplayTime: DisplayTimeOption = .month
    
//    @State private var symptomNames = [String]() // filled in .onAppear, with inserting 'All'
    
    // in order for Chart view @Query filtering to work dynamically selections needs to happen outside the Chart view
    @State private var selectedSymptoms: Set<Symptom>?
    @State private var selectedSideEffects: Set<Symptom>?
    @State private var selectedSingleSymptom: Symptom?
    @State private var selectedMedicines: Set<Medicine>?
    @State private var selectedEventCategories: Set<EventCategory>?
    @State private var selectedDiaryEvent: DiaryEvent?
    @State var selectedEventCategory: EventCategory?
    
    @State var startDisplayDate: Date = DatesManager.monthStartAndEnd(ofDate: .now).first!
    @State var endDisplayDate: Date = DatesManager.monthStartAndEnd(ofDate: .now).last!
    
    @State var dragOffset = CGSizeZero
    @State var showRatingButton = false
    @State var selectedVAS: Double?
    @State var addRatingOrEventSubtitle = UserText.term("Rate symptom or record an event\n(Chose the rated symptom in the next step)")

    @State var showNewCategoryView = false
    @State var showNewEventView = false
    @State var showNewMedicineEventView = false
    @State var showNewSymptomView = false
    @State var showSideEffects = true

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
                            }
                        }
                        Text(DatesManager.displayPeriodTerm(_for: selectedDisplayTime, start: startDisplayDate, end: endDisplayDate)).bold()
                        Button("", systemImage: "chevron.right") {
                            withAnimation {
                                stepDisplayTime(option: .forwards)
                            }
                        }
                    }
                    .padding(.bottom, -5)
                }
                
                ScrollView {
                    VStack(alignment: .leading) {
                        //MARK: - Ratings and Med event charts
                        if selectedDisplayTime == DisplayTimeOption.quarter || selectedDisplayTime == DisplayTimeOption.year {
                            
                            Ratings_Medicines_ChartView2(selectedSymptoms: $selectedSymptoms, symptoms: allSymptoms, selectedSideEffects: $selectedSideEffects,  sideEffects: allSideEffects, selectedMedicines: $selectedMedicines, medicines: allMedicines, from: startDisplayDate, to: endDisplayDate, displayTime: selectedDisplayTime, showRatingButton: $showRatingButton, showNewSymptomView: $showNewSymptomView, showSideEffects: $showSideEffects)
                                .frame(minHeight: 600)
                                .padding(.horizontal)

                            if showRatingButton {
                                    Divider()
                                RatingButton(showView: $showRatingButton, vas: $selectedVAS, headerSubtitle: $addRatingOrEventSubtitle, showNewEventView: $showNewEventView, showNewMedicineEventView: $showNewMedicineEventView)
                                    .frame(minHeight: 300)
                                    .padding(.horizontal)

                                Divider()
                            }
                        } else {
                            Ratings_Medicines_ChartView(selectedSymptoms: $selectedSymptoms, symptoms: allSymptoms, selectedSideEffects: $selectedSideEffects,  sideEffects: allSideEffects, selectedMedicines: $selectedMedicines, medicines: allMedicines, selectedEvent: $selectedDiaryEvent, from: startDisplayDate, to: endDisplayDate, displayTime: selectedDisplayTime, showRatingButton: $showRatingButton, showNewSymptomView: $showNewSymptomView, showSideEffects: $showSideEffects)
                                .frame(minHeight: 300)
                                .frame(maxHeight: 450)
                                .padding(.horizontal)
                            
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
                                        stepDisplayTime(option: .backwards)
                                    }
                                } else if dragOffset.width < 0 {
                                    withAnimation {
                                        stepDisplayTime(option: .forwards)
                                    }
                                }
                            })
                    )
                    VStack(alignment: .leading) {
                        //MARK: - Events Charts
                        if selectedDisplayTime == DisplayTimeOption.quarter || selectedDisplayTime == DisplayTimeOption.year {
                            EventsChartView2(selectedCategories: $selectedEventCategories, showNewCategoryView: $showNewCategoryView, allCategories: allEventCategories, from: startDisplayDate, to: endDisplayDate)
//                                .frame(minHeight: 300)
//                                .frame(maxHeight: 450)
                                .padding(.horizontal)

                        }
                        else {
                            EventsChartView(selectedCategories: $selectedEventCategories, showNewCategoryView: $showNewCategoryView, selectedDiaryEvent: $selectedDiaryEvent, allCategories: allEventCategories, from: startDisplayDate, to: endDisplayDate)
                                .frame(minHeight: 250)
                                .padding(.horizontal)

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
                            .padding(.horizontal)

                        }
                    }
                }
                .scrollDisabled(showRatingButton)
                
            }
            .sheet(isPresented: $showRatingButton, content: {
                VStack {
                    Text(UserText.term("Add a diary entry")).font(.title).bold()
                    Text(UserText.term(addRatingOrEventSubtitle)).foregroundStyle(.gray)
                    Divider()
                    RatingButton(showView: $showRatingButton, vas: $selectedVAS, headerSubtitle: $addRatingOrEventSubtitle, showNewEventView: $showNewEventView, showNewMedicineEventView: $showNewMedicineEventView)
                        .padding(.horizontal)
                    
                    Divider()
                }.navigationTitle("Add a symptom rating or event")
                    .padding()
            })
            .sheet(isPresented: $showNewCategoryView, content: {
                NewCategoryView(showView: $showNewCategoryView, newCategorySelection: $selectedEventCategory)
            })
            .sheet(isPresented: $showNewEventView, content: {
                NewEventView(categories: allEventCategories, showView: $showNewEventView, category: allEventCategories.first)
            })
            .sheet(isPresented: $showNewMedicineEventView, content: {
                NewMedicineEventView(showView: $showNewMedicineEventView)
            })
            .sheet(isPresented: $showNewSymptomView, content: {
                NewSymptomView(showView: $showNewSymptomView, selectedSymptom: $selectedSingleSymptom)
            })
            .onAppear {
//                symptomNames = allSymptoms.compactMap{ $0.name }
                
                //                cleanRatingDuplicates()
            }
            .onChange(of: selectedSymptoms) { _, _ in
                adjustSelectedSymptomsForCharts()
            }
//            .onChange(of: selectedMedicines) { _, _ in
//                adjustSelectedMedicinesForCharts()
//            }

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
   }
    
    private func adjustSelectedSymptomsForCharts() {
        
        var symptomRelatedMeds = Set<Medicine>()
        if let validSelectedSymptoms = selectedSymptoms {
            selectedMedicines = Set<Medicine>()
            selectedSideEffects = Set<Symptom>()
            
            for symptom in validSelectedSymptoms {
                for med in symptom.treatingMeds ?? [] {
                    selectedMedicines?.insert(med)
                    for se in med.sideEffects ?? [] {
                        selectedSideEffects?.insert(se)
                    }
                }
            }
        } else {
            selectedMedicines = nil
        }
        
    }
    
//    private func adjustSelectedMedicinesForCharts() {
//        
//        selectedSymptoms = Set<Symptom>()
//        if let validSelectedMeds = selectedMedicines {
//            for med in validSelectedMeds {
//                for symptom in med.treatedSymptoms ?? [] {
//                    selectedSymptoms?.insert(symptom)
//                }
//                for se in med.sideEffects ?? [] {
//                    selectedSymptoms?.insert(se)
//                }
//            }
//        } else {
//            selectedSymptoms = Set(allSymptoms)
//        }
//        
//    }

        
    func cleanRatingDuplicates() {
        
        let fetchDescriptorS = FetchDescriptor<Rating>(sortBy: [SortDescriptor(\Rating.date)])
        if let existingSymptoms = try? modelContext.fetch(fetchDescriptorS) {
            var ratingsToDelete = [Rating]()
            for i in 1..<existingSymptoms.count {
                let current = existingSymptoms[i]
                let previous = existingSymptoms[i-1]
                
                if current.vas == previous.vas {
                    if (current.ratedSymptom?.name ?? "none") == (previous.ratedSymptom?.name ?? "none") {
                        if current.date.timeIntervalSince(previous.date) < 60 {
                            ratingsToDelete.append(current)
                        }
                    }
                }
                
                for rating in ratingsToDelete {
                    modelContext.delete(rating)
                }
            }
        }
        
    }
}

#Preview {
    GraphicDiaryView()
}
