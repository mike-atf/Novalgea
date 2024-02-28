//
//  DiaryEvent.swift
//  Novalgea
//
//  Created by aDev on 04/02/2024.
//
//

import Foundation
import SwiftData


@Model final class DiaryEvent: Identifiable {
    
    var category: String = "Category"
    var date: Date = Date()
    var endDate: Date?
    var notes: String = ""
    var uuid: UUID = UUID()
    
    @Relationship(deleteRule: .nullify, inverse: \Rating.relatedDiaryEvents) var relatedRatings: [Rating]?
    @Relationship(deleteRule: .nullify, inverse: \Symptom.diaryEvents) var relatedSymptoms: [Symptom]?
    
    public init(date: Date?, category: String, relatedRatings: [Rating]? = [], relatedSymptoms: [Symptom]? = [], notes: String = "") { // the relatedRatings: [Rating]? = [] is essential to prevent preview crashes!
        self.date = date ?? .now
        self.category = category
        self.notes = notes
        self.relatedRatings = relatedRatings
    }
}

extension DiaryEvent {
    
    static var preview: DiaryEvent {
        DiaryEvent(date: .now.addingTimeInterval(-TimeInterval.random(in: 0...30*24*3600)), category: "Default event category")
            
    }

}

