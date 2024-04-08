//
//  Rating.swift
//  Novalgea
//
//  Created by aDev on 04/02/2024.
//
//

import Foundation
import SwiftData


@Model class Rating: Identifiable, Equatable  {
    
    var date: Date = Date()
    var vas: Double = 0.0
    var ratedSymptom: Symptom? // should be either Symptom or Medicine
    var ratedMedicine: Medicine? // effect rating 10 complete - 0 none.
    var note: String?
    var uuid: UUID = UUID()

    var relatedDiaryEvents: [DiaryEvent]? = []
    var relatedExerciseEvents: ExerciseEvent?
    var relatedMedEvents: [MedicineEvent]?
    
    init(vas: Double, ratedSymptom: Symptom?, date: Date? = nil, note: String? = nil, uuid: UUID = UUID(), relatedDiaryEvents: [DiaryEvent]? = [], relatedExerciseEvents: ExerciseEvent? = nil, relatedMedEvents: [MedicineEvent]? = [], ratedMedicine: Medicine? = nil) {
        // the relatedDiaryEvents: [DiaryEvent]? = [] (not = nil) is essential to prevent preview crashes!
        self.date = date ?? .now
        self.note = note
        self.uuid = uuid
        self.vas = vas
        self.ratedSymptom = ratedSymptom
        self.relatedDiaryEvents = relatedDiaryEvents
        self.relatedExerciseEvents = relatedExerciseEvents
        self.relatedMedEvents = relatedMedEvents
        self.ratedMedicine = ratedMedicine
    }
    
    static func == (lhs: Rating, rhs: Rating) -> Bool {
        
        if lhs.note != rhs.note { return false }
        if abs(lhs.date.timeIntervalSince(lhs.date)) > 5 { return false }
        if lhs.ratedSymptom != rhs.ratedSymptom { return false }
        if lhs.vas != rhs.vas { return false }
        
        return true
        
    }

    
    /// converts Alogea effectiveness (String) to VAS for medicine rating on import
    public func effectAsVAS(effect: MedicineEffectRating, medicine: Medicine) {
        switch effect {
        case .none:
            self.vas = 0
        case .minor:
            self.vas = 2
        case .moderate:
            self.vas = 4.0
        case .good:
            self.vas = 7.0
        case .complete:
            self.vas = 10
        }
        self.ratedMedicine = medicine
    }
    
    @MainActor public func ratedUserText() -> String {
        
        if ratedSymptom != nil { return ratedSymptom!.name }
        else if ratedMedicine != nil {
            return UserText.term("Effect of ") + ratedMedicine!.name
        }
        else {
            let rDate = self.date.formatted()
            let ierror = InternalError(file: "Rating", function: "ratedUserText()", appError: "rating with date \(rDate) with neither ratedSymptom nor ratedMedicine")
            ErrorManager.addError(error: ierror, container: self.modelContext!.container)
            return ""
        }
    }
    
    public func ratedSymptomIsAmong(symptoms: [Symptom]) -> Bool {
        
        guard let rSymptom = ratedSymptom else { return false }
        
        return symptoms.contains(rSymptom)
    }
    
    
    
}

enum MedicineEffectRating: String {
    case none = "none"
    case minor = "minor"
    case moderate = "moderate"
    case good = "good"
    case complete = "complete"
}

extension Rating {
    
    static var preview: Rating {
        
        Rating(vas: 5.5, ratedSymptom: Symptom(name: "Sample symptom created in sample rating", type: "Symptom", creatingDevice: "Sample device"))
    }

}

