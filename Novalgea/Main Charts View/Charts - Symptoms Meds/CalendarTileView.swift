//
//  CalendarTileView.swift
//  Novalgea
//
//  Created by aDev on 19/04/2024.
//

import SwiftUI
import SwiftData
import OSLog

struct CalendarTileView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query var symptoms: [Symptom]
    
    @State var selectedRatings = FetchDescriptor<Rating>()
    @State var selectedSymptom: Symptom? = nil
    @State var startDate: Date = DatesManager.startOfMonth(from: .now, _by: 0)
    @State var dailyVAScores = [Int: [Double]]()
    @State var showDatePicker = false

    let weekDayNames = Calendar.current.shortWeekdaySymbols
    
    var sunLastWeekdayNames: [String] {
        var changed = Array(weekDayNames.dropFirst())
        changed.append(weekDayNames.first!)
        return changed
    }
    
    var numberOfDays: Int {
        return DatesManager.daysOfMonth(from: startDate)
    }
    
    var startingWeekday: Int {
        let originalWeekday = DatesManager.weekday(of: startDate)
        var monToSunWeekday = originalWeekday - 1
        if monToSunWeekday < 0 { monToSunWeekday += 7 }
        return monToSunWeekday
        // accounting for Sunday(0) now last = 7
    }
    var weeksThisMonth: Int {
        return Int(numberOfDays/weekDayNames.count) + 1
    }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Picker("Symptom", selection: $selectedSymptom) {
                ForEach(symptoms) {
                    symptom in
                    Text(symptom.name).tag(Optional(symptom))
                }
            }
            .onChange(of: selectedSymptom) { oldValue, newValue in
                dailyVAScores = getRatingAverages()
                UserDefaults.standard.setValue(selectedSymptom?.uuid.uuidString, forKey: Userdefaults.lastSelectedSymptom.rawValue)
            }

            HStack {
                
                Button {
                    withAnimation {
                        startDate = DatesManager.startOfMonth(from: startDate, _by: -1)
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Button {
                    showDatePicker.toggle()
                } label: {
                    Text(startDate, format: Date.FormatStyle().month().year()).bold().font(.title3)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showDatePicker) {
                    YearMonthPickerView(selectedDate: $startDate, endDate: .constant(nil))
                }
                
                Button {
                    withAnimation {
                        startDate = DatesManager.startOfMonth(from: startDate, _by: +1)
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                Spacer()
                
            }
            .padding(.bottom)
            
        Grid(alignment: .center) {
            
            GridRow {
                ForEach(sunLastWeekdayNames, id: \.self) { day in
                    Text(day).bold().foregroundStyle(.secondary)
                }
            }
            
            ForEach(0...weeksThisMonth, id: \.self) { weekNo in
                
                Divider()
                
                GridRow {
                    
                    ForEach(0..<weekDayNames.count, id: \.self) { weekday in
                        
                        let day = weekNo * weekDayNames.count + weekday + 1 - startingWeekday
                        
                        ZStack(alignment: .top) {
                            
                            if day > 0 && day <= numberOfDays {

                                if let vasScores = dailyVAScores[day] {
                                    let avg = vasScores.mean()
                                    let vasColor = ColorScheme.gradientColors.getColor(_for: avg)
                                    vasColor
                                } else {
                                    Color.clear
                                }
                                Text(day.formatted())

                            }
                            else {
                                Text("")
                                Color.clear
                            }
                        }
                    }
                }
            }
        }
        .transition(.move(edge: .trailing))
    }
        .padding(.horizontal)
        .onAppear {
            if selectedSymptom == nil {
                if let symptomUUIDstring = UserDefaults.standard.value(forKey: Userdefaults.lastSelectedSymptom.rawValue) as? String {
                    if let latest = symptoms.filter({ s in
                        if s.uuid.uuidString != symptomUUIDstring { return false }
                        else { return true }
                    }).first {
                        selectedSymptom = latest
                    } else {
                        selectedSymptom = symptoms.first
                    }
                } else {
                    selectedSymptom = symptoms.first
                }
            }
            dailyVAScores = getRatingAverages()
        }
        .onChange(of: startDate) { _, _ in
            dailyVAScores = getRatingAverages()
        }
    }
    
    private func getRatingAverages() -> [Int:[Double]] {
        
        
        var lnewDailyAverage = [Int:[Double]]()
        
        let endOfMonth = DatesManager.monthStartAndEnd(ofDate: startDate).last!
        
        let thisMonthsEvents = selectedSymptom?.ratingEvents?.filter({ rating in
            if rating.date < startDate { return false }
            else if rating.date > endOfMonth { return false }
            else { return true }
        })
        
        for rating in thisMonthsEvents ?? [] {
            let day = rating.date.dayOfMonth()
            if var exists = dailyVAScores[day] {
                exists.append(rating.vas)
            } else {
                lnewDailyAverage[day] = [rating.vas]
            }
        }
        
        return lnewDailyAverage
    }
}

#Preview {
    CalendarTileView(startDate: DatesManager.startOfMonth(_by: 0)).modelContainer(DataController.previewContainer)
}
