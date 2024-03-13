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

    @State var startDisplayDate: Date = (Date().setDate(day: 1, month: 1, year: 2020) ?? .now).addingTimeInterval(-30*24*3600)
    @State var endDisplayDate: Date = Date().setDate(day: 1, month: 1, year: 2020) ?? .now
    @State var dragOffset = CGSizeZero

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Section {
                    DiarySelectionSection(selectedDisplayTime: $selectedDisplayTime, startDisplayDate: $startDisplayDate, endDisplayDate: $endDisplayDate)
                    HStack {
                        Button("", systemImage: "chevron.left") {
                            withAnimation {
                                startDisplayDate = startDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
                                endDisplayDate = endDisplayDate.addingTimeInterval(-selectedDisplayTime.timeValue)
                            }
                        }
                        Text(DatesManager.displayPeriodTerm(_for: selectedDisplayTime, start: startDisplayDate, end: endDisplayDate)).font(.title2).bold()
                        Button("", systemImage: "chevron.right") {
                            withAnimation {
                                startDisplayDate = startDisplayDate.addingTimeInterval(selectedDisplayTime.timeValue)
                                endDisplayDate = endDisplayDate.addingTimeInterval(selectedDisplayTime.timeValue)
                            }
                        }
                    }.padding(.bottom, -5)
                }
                ScrollView {
//                    Section {
                        VStack(alignment: .leading) {
                            if selectedDisplayTime == DisplayTimeOption.quarter || selectedDisplayTime == DisplayTimeOption.year {
                                Ratings_Medicines_ChartView2(selectedSymptoms: $selectedSymptoms, symptoms: symptomsList, selectedMedicines: $selectedMedicines, medicines: medicinesList, from: startDisplayDate, to: endDisplayDate, displayTime: selectedDisplayTime)
                                    .frame(height: geometry.size.height * 0.8)
                            } else {
                                Ratings_Medicines_ChartView(selectedSymptoms: $selectedSymptoms, symptoms: symptomsList, selectedMedicines: $selectedMedicines, medicines: medicinesList, selectedEvent: $selectedDiaryEvent, from: startDisplayDate, to: endDisplayDate, displayTime: selectedDisplayTime)
                                    .frame(height: geometry.size.height * 0.5)
                            }
                        }
                        .gesture(
                            DragGesture()
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
                            if selectedDisplayTime == DisplayTimeOption.quarter || selectedDisplayTime == DisplayTimeOption.year {
                                EventsChartView2(selectedCategories: $selectedEventCategories, allCategories: allEventCategories, from: startDisplayDate, to: endDisplayDate)
                                    .frame(height: geometry.size.height * 0.4)

                            }
                            else {
                                EventsChartView(selectedCategories: $selectedEventCategories, selectedDiaryEvent: $selectedDiaryEvent, allCategories: allEventCategories, from: startDisplayDate, to: endDisplayDate)
                                    .frame(height: geometry.size.height * 0.3)

                            }
                        }
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
//                }
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
