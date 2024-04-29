//
//  RatingEditView.swift
//  Novalgea
//
//  Created by aDev on 28/04/2024.
//

import SwiftUI
import SwiftData

struct RatingEditView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @Query var symptoms: [Symptom]
    
    @Binding var rating: Rating?
    
    @State var selectedSymptom: Symptom = Symptom.placeholder
    @State var selectedVAS: Double = 0
    @State var selectedDate: Date = .now

    var body: some View {
        List {
            Section {
                
                Text(UserText.term("Edit symptom rating")).bold().font(.title)
                                
                HStack {
                    Text(selectedVAS * 10,format: .number.precision(.fractionLength(1)))
                        .padding(.trailing).bold().font(.title3)

                    Slider(value: $selectedVAS) {
                        Text("VAS")
                    } minimumValueLabel: {
                        Text("0")
                    } maximumValueLabel: {
                        Text("10")
                    }
                    .padding(.horizontal)
                }
            }
            
            Section {
                Picker(selection: $selectedSymptom) {
                    ForEach(symptoms, id: \.self) { symptom in
                        Text(symptom.name).foregroundStyle(symptom.color())
                    }
                } label: {
                    HStack {
                        Image(systemName: "bolt.circle.fill").imageScale(.large).foregroundStyle(.orange)
                        Text(UserText.term("Symptom")).bold().font(.title3)
                    }
                }
            }
            
            Section {
                DatePicker(selection: $selectedDate) {
                    HStack {
                    Image(systemName: "calendar.circle.fill").imageScale(.large).foregroundStyle(.orange)
                    Text(UserText.term("Date")).bold().font(.title3)
                }
                }
            }
            
            Section {
                Button {
                    save()
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(Font.title2.bold())
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.blue)
            }
            
            Section {
                Button {
                    cancel()
                } label: {
                    Text("Cancel")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(Font.title2.bold())
                        .foregroundColor(.red)
                }
            }

        }
        .onChange(of: rating, { oldValue, newValue in
            updateSelection() //crashes preview
        })
        .onAppear {
            updateSelection() //crashes preview
        }
    }
    
    private func updateSelection() {
        selectedSymptom = rating?.ratedSymptom ?? Symptom.placeholder
        selectedVAS = (rating?.vas ?? 0) / 10
        selectedDate = rating?.date ?? .now
    }
    
    private func save() {
        
        rating?.vas = selectedVAS * 10
        rating?.ratedSymptom = selectedSymptom
        rating?.date = selectedDate
        
        saveContext()

        rating = nil // triggers backward navigation
    }
    
    private func cancel() {
        rating = nil // triggers backward navigation
    }
    
    private func saveContext() {
        DispatchQueue.main.async {
            do {
                try modelContext.save()
            } catch {
                let ierror = InternalError(file: "RatingEditView", function: "saveContext", appError: error.localizedDescription)
                ErrorManager.addError(error: ierror, container: modelContext.container)
            }
        }
    }

    
    
}

#Preview {
    RatingEditView(rating: .constant(Rating.preview)).modelContainer(DataController.previewContainer)
}
