//
//  RatingButton.swift
//  Novalgea
//
//  Created by aDev on 14/03/2024.
//

import SwiftUI
import CoreGraphics
import SwiftData

struct RatingButton: View {
    
    @Environment(\.modelContext) private var modelContext

    @Query(filter: #Predicate<Medicine> { medicine in
        medicine.isRegular == false &&
        medicine.currentStatus == "Current"
    }, sort: \Medicine.startDate, order: .reverse) var prnMedicines: [Medicine]
    
    @Query(sort: \Symptom.name) var symptoms: [Symptom]

    @Binding var showView: Bool
    @Binding var vas: Double?

    @State var showMedicineList = false
    @State var showSymptomsList = false
    @State var showDateSelector = false

    @State var selectedMedicine: Medicine?
    @State var selectedSymptom: Symptom?
    @State var selectedEventDate = Date.now
    @State var customDate$: String?
    @State var circleSize = 1.0
    
    @State var selectedVAS: Double?
    
    private let segment = Angle(degrees: 5)
    private let angularGradientColors = [.white, Color(red: 251/255, green: 247/255, blue: 118/255), Color(red: 255/255, green: 161/255, blue: 34/255), Color(red: 151/255, green: 60/255, blue: 56/255)]

        
    var body: some View {
        GeometryReader { reader in
            
            let min = min(reader.size.width, reader.size.height)
            
            HStack(alignment: .center) {
                if showMedicineList {
                    List {
                        ForEach(prnMedicines) { med in
                            Button {
                                selectedMedicine = med
                                addMedicineEvent()
                            } label: {
                                HStack {
                                    Text(med.name).font(.caption)
                                    if let valid = selectedMedicine {
                                        if valid == med {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .environment(\.defaultMinListRowHeight, 30)
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .transition(.move(edge: .leading))

                }
                else if showSymptomsList {
                    List {
                        ForEach(symptoms) { symptom in
                            Button {
                                selectedSymptom = symptom
                                addMedicineEvent()
                            } label: {
                                HStack {
                                    Text(symptom.name).font(.caption)
                                    if let valid = selectedSymptom {
                                        if valid == symptom {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }

                        }
                    }
                    .environment(\.defaultMinListRowHeight, 30)
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .transition(.move(edge: .leading))

                }
                
                if !(showMedicineList || showSymptomsList) {
                    ZStack(alignment: .center) {
                            //MARK: - Circular slider with Triangle overlay
                            ZStack(alignment: .top)
                            {
                                Circle()
                                    .stroke(Color.black, style: StrokeStyle(lineWidth:5))
                                    .strokeBorder(angulargradient, style: StrokeStyle(lineWidth: reader.size.height * 0.25))
                                    .gesture(
                                        DragGesture(minimumDistance: 10)
                                            .onChanged({ value in
                                                let center = CGPoint(x: reader.frame(in: .local).midX, y:reader.frame(in: .local).midY)
                                                let distance = CGPoint(x: value.location.x - center.x, y: value.location.y - center.y)
                                                vasUpdate(location: distance)
                                            })
                                            .onEnded({ _ in
                                                vas = selectedVAS
                                                showSymptomsList = true
                                            })
                                    )
                                    .sensoryFeedback(.increase, trigger: selectedVAS)
                                Triangle()
                                    .fill(gradientRed)
                                    .frame(width: 16, height: reader.size.height * 0.25)
                                    .offset(CGSize(width: -8, height: 0)) //- 27
                                                                
                            }
                            .scaleEffect(circleSize)
                        
                        //MARK: - VAS indicator on outside of circle
                        ZStack(alignment: .top) {
                            Circle()
                                .hidden()
                                Indicator()
                                    .stroke(Color.black, lineWidth: 1)
                                    .fill(getColor(vas: (selectedVAS ?? 0)))
                                    .frame(width: 35, height: 25)
                                    .offset(y: -20)
                                
                                Text((selectedVAS ?? 0.0),format: .number.precision(.fractionLength(1)))
                                    .foregroundStyle(indicatorTextColor(vas: selectedVAS ?? 0))
                                    .font(.system(size: 14))
                                    .bold()
                                    .offset(y:-15)
                        }
                        .scaleEffect(circleSize)
                        .rotationEffect(Angle(radians: (selectedVAS ?? 0.0)/10 * (-2 * .pi)))

                        //MARK: - Round button
                        Button {
                            withAnimation(.easeInOut) {
                                circleSize = 0.0
                                showMedicineList = true
                            }
                        } label: {
                            ZStack(alignment: .center) {
                                Circle()
                                    .fill(Color(red: 0/255, green: 44/255, blue: 81/255))
                                    .scaleEffect(circleSize)
                                Image(systemName: "pills.fill")
                                    .imageScale(.large)
                                    .font(.system(size: 30))
                                    .foregroundStyle(.white)
                                    .scaleEffect(circleSize)
                            }
                        }
                        .frame(width: min * 0.48,height: min * 0.48)
                        
                    }
                }
                
                if (showMedicineList || showSymptomsList) {
                    List {
                        Button {
                            selectedMedicine = nil
                            selectedSymptom = nil
                            selectedVAS = nil
                            withAnimation {
                                showView = false
                            }
                        } label: {
                            Text(UserText.term("Cancel")).font(.caption).foregroundStyle(.red)
                        }
                        Button {
                            selectedEventDate = .now
                            addEvent()
                        } label: {
                            Text(UserText.term("Now")).font(.caption)
                        }

                        Button {
                            selectedEventDate = .now.addingTimeInterval(-1800)
                            addEvent()
                        } label: {
                            Text(UserText.term("30 min ago")).font(.caption)
                        }
                        Button {
                            selectedEventDate = .now.addingTimeInterval(-3600)
                            addEvent()
                        } label: {
                            Text(UserText.term("1 h ago")).font(.caption)
                        }
                        Button {
                            selectedEventDate = .now.addingTimeInterval(-2*3600)
                            addEvent()
                        } label: {
                            Text(UserText.term("2 h ago")).font(.caption)
                        }
                        Button {
                            showDateSelector = true
                        } label: {
                            Text(customDate$ ?? UserText.term("Other date...")).font(.caption)
                        }
                        .popover(isPresented: $showDateSelector) {
                            VStack {
                                Text(UserText.term("Start of medication event")).font(.title).bold()
                                DatePicker("", selection: $selectedEventDate)
                                    .datePickerStyle(.graphical)
                                Button(UserText.term("Done")) {
                                    showDateSelector = false
                                }.buttonStyle(BorderedProminentButtonStyle())
                            }
                            .padding()
                        }.presentationCompactAdaptation(.none)
                            .onChange(of: selectedEventDate) { oldValue, newValue in
                                customDate$ = selectedEventDate.formatted(.dateTime.day().month().hour().minute())
                            }
                    }
                    .environment(\.defaultMinListRowHeight, 30)
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                    .transition(.move(edge: .trailing))
                }

            }
            .onAppear {
                if prnMedicines.count < 2 {
                    _selectedMedicine.wrappedValue = prnMedicines.first
                }
            }
        }
    }
    
    func addEvent() {
        
        if selectedMedicine != nil { addMedicineEvent() }
        else if selectedSymptom != nil { addRatingEvent() }
    }
    
    func addMedicineEvent() {
        
        guard selectedMedicine != nil else { return }

        let newMedEvent = MedicineEvent(endDate: selectedEventDate.addingTimeInterval(selectedMedicine!.effectDuration), startDate: selectedEventDate, medicine: selectedMedicine!)
        modelContext.insert(newMedEvent)
        saveContext()
        withAnimation {
            showView = false
        }
        selectedMedicine = nil
    }
    
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
    
    func vasUpdate(location: CGPoint) {
        
        let vector = CGVector(dx: location.x, dy: location.y)
        let rawAngle = atan2(vector.dx, vector.dy) + .pi
        let angle = rawAngle < 0.0 ? rawAngle + 2 * .pi : rawAngle
        selectedVAS = angle / (2 * .pi) * 10 // TODO: - add in current symptom minVAS and maxVAS
    }
    
    func getColor(vas: Double) -> Color {
        return angularGradientColors.getColor(_for: vas)
    }
    
    
    func indicatorTextColor(vas: Double) -> Color {
        
        if vas > 5 { return .white }
        else { return .black }
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
    RatingButton(showView: .constant(true), vas: .constant(nil))
}


struct Triangle: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        
        return path
    }
}

struct Indicator: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY-rect.height/4))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
//        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY-rect.height/4))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
    
    
    
}

