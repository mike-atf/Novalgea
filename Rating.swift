//
//  Rating.swift
//  Novalgea
//
//  Created by aDev on 04/02/2024.
//
//

import Foundation
import SwiftData


@Model class Rating: Identifiable  {
    
    var date: Date = Date()
    var vas: Double = 0.0
    var ratedSymptom: Symptom?
    var note: String?
    var uuid: UUID = UUID()

    var relatedDiaryEvents: [DiaryEvent]? = []
    var relatedExerciseEvents: ExerciseEvent?
    var relatedPRNMedEvents: [PRNMedEvent]?
    
    init(vas: Double, ratedSymptom: Symptom, date: Date? = nil, note: String? = nil, uuid: UUID = UUID(), relatedDiaryEvents: [DiaryEvent]? = [], relatedExerciseEvents: ExerciseEvent? = nil, relatedPRNMedEvents: [PRNMedEvent]? = []) {
        // the relatedDiaryEvents: [DiaryEvent]? = [] (not = nil) is essential to prevent preview crashes!
        self.date = date ?? .now
        self.note = note
        self.uuid = uuid
        self.vas = vas
        self.ratedSymptom = ratedSymptom
        self.relatedDiaryEvents = relatedDiaryEvents
        self.relatedExerciseEvents = relatedExerciseEvents
        self.relatedPRNMedEvents = relatedPRNMedEvents
    }
}

extension Rating {
    
    static var preview: Rating {
        
        Rating(vas: 5.5, ratedSymptom: Symptom(name: "Sample symptom", type: "Symptom", creatingDevice: "Sample device"))
    }

}

