//
//  RatingButton.swift
//  Novalgea
//
//  Created by aDev on 14/03/2024.
//

import SwiftUI
import CoreGraphics
import SwiftData
import OSLog

struct RatingButton: View {
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.verticalSizeClass) var verticalSizeClass
//    @Query(filter: #Predicate<Medicine> { medicine in
//        medicine.isRegular == false &&
//        medicine.currentStatus == "Current"
//    }, sort: \Medicine.name, order: .reverse) var prnMedicines: [Medicine]
    
//    @Query(sort: \Symptom.name) var symptoms: [Symptom]
    @Query() var events: [DiaryEvent]
    @Query(sort: \EventCategory.name) var eventCategories: [EventCategory]

    @Binding var showView: Bool
    @Binding var vas: Double?
    @Binding var headerSubtitle: String
    @Binding var showNewEventView: Bool
    @Binding var showNewMedicineEventView: Bool

    @State var showMedicineList = false
    @State var showSymptomsList = false
    @State var showDateSelector = false
    @State var showSymptomEntry = false
    @State var showNewCategory = false

    @State var selectedMedicine: Medicine?
    @State var selectedSymptom: Symptom?
    @State var selectedEventDate = Date.now
    @State var customDate$: String?
    
    @State var selectedVAS: Double?
    @State var selectedEventCategory: EventCategory?
    
    private let segment = Angle(degrees: 5)
    private let angulargradient = AngularGradient(colors: gradientColors, center: .center, startAngle: .degrees(270), endAngle: .degrees(-90))

    var body: some View {
        
        GeometryReader { reader in
            let min = min(reader.size.width, reader.size.height)

            if showSymptomsList {
                
                
                List {
                    Section {
                        SymptomListPickerView(selectedSymptom: $selectedSymptom, showSymptomEntry: $showSymptomEntry)
                    }
                    Spacer()
                    Section {
                        BackdatingOptionView(selectedEventDate: $selectedEventDate)
                    }
                    
                    Spacer()
                    Section {
                        Button {
                            addRatingEvent()
                        } label: {
                            Text("Save")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(Font.title2.bold())
                                .foregroundColor(.white)
                        }
                        .listRowBackground(selectedSymptom == nil ? Color.gray : Color.blue)
                        
                        Button {
                            showView = false
                        } label: {
                            Text("Cancel")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .font(Font.title2.bold())
                                .foregroundColor(.red)
                        }

                   }
                }
                .sheet(isPresented: $showSymptomEntry, content: {
                    NewSymptomView(showView: $showSymptomEntry)
                })
                .sheet(isPresented: $showNewCategory, content: {
                    NewCategoryView(showView: $showNewCategory, newCategorySelection: $selectedEventCategory)
                })
                .listStyle(.plain)
            }
            else {
                VStack {
                    //MARK: - facial expression circle

                    if verticalSizeClass == .regular {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.duskBlue)
                            
                            FacialRatingView(vas: $selectedVAS, textSize: (min/3).rounded())
                            
                        }
                        .padding(.horizontal)
                        .frame(maxHeight: min/3)
                    }
                    VerbalRatingView(vas: $selectedVAS)
                        .frame(maxHeight:35)
                        .padding(.horizontal)
                        
                        //MARK: - circular slider & button
                    CircularSliderView(vas: $vas, selectedVAS: $selectedVAS, showNewEventView: $showNewEventView, showNewMedicineEventView: $showNewMedicineEventView, showSymptomsList: $showSymptomsList, showView: $showView, headerSubTitle: $headerSubtitle)
                    
                    Spacer()
                    
                    Button(UserText.term("Cancel")) {
                        showView = false
                    }
                    .buttonStyle(BorderedButtonStyle())

                }
            }
        }
            
    }
    
//    func addEvent() {
//        
//        if selectedMedicine != nil { addMedicineEvent() }
//        else if selectedEventCategory != nil { addDiaryEvent() }
//        else if selectedSymptom != nil { addRatingEvent() }
//    }
    
//    func addMedicineEvent() {
//        
//        guard selectedMedicine != nil else { return }
//
//        let newMedEvent = MedicineEvent(endDate: selectedEventDate.addingTimeInterval(selectedMedicine!.effectDuration), startDate: selectedEventDate, medicine: selectedMedicine!)
//        modelContext.insert(newMedEvent)
//        saveContext()
//        withAnimation {
//            showView = false
//        }
//        selectedMedicine = nil
//    }
    
//    func addDiaryEvent() {
//        
//        let newEvent = DiaryEvent(date: selectedEventDate, category: selectedEventCategory!)
//        modelContext.insert(newEvent)
//        saveContext()
//        withAnimation {
//            showView = false
//        }
//        selectedEventCategory = nil
//
//    }
    
    func addRatingEvent() {
        
        guard selectedSymptom != nil else { return }
        guard vas != nil else { return }

        let newRating = Rating(vas: vas!, ratedSymptom: selectedSymptom!, date: selectedEventDate)
        modelContext.insert(newRating)
        saveContext()
        withAnimation {
            showView = false
        }
        selectedSymptom = nil
    }
    
    private func saveContext() {
        DispatchQueue.main.async {
            do {
                try modelContext.save()
            } catch {
                let ierror = InternalError(file: "RatingButton", function: "addRatingEvent", appError: error.localizedDescription)
                ErrorManager.addError(error: ierror, container: modelContext.container)
            }
        }
    }
}

#Preview {
    RatingButton(showView: .constant(true), vas: .constant(nil), headerSubtitle: .constant("Record a symptom rating or an event"), showNewEventView: .constant(false), showNewMedicineEventView: .constant(true)).modelContainer(DataController.previewContainer)
}



