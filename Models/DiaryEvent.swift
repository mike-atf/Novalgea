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
    
//    var category: String = "Category"
    var date: Date = Date()
    var endDate: Date?
    var notes: String = ""
    var uuid: UUID = UUID()
    
    @Relationship(deleteRule: .nullify, inverse: \Rating.relatedDiaryEvents) var relatedRatings: [Rating]?
    @Relationship(deleteRule: .nullify, inverse: \Symptom.diaryEvents) var relatedSymptoms: [Symptom]?
    @Relationship(deleteRule: .nullify, inverse: \EventCategory.relatedDiaryEvents) var category: EventCategory?

    public init(date: Date?, endDate: Date?=nil, category: EventCategory, relatedRatings: [Rating]? = [], relatedSymptoms: [Symptom]? = [], notes: String = "") { // the relatedRatings: [Rating]? = [] is essential to prevent preview crashes!
        self.date = date ?? .now
        if let end = endDate {
            if end > self.date { self.endDate = end }
        }
        self.category = category
        self.notes = notes
        self.relatedRatings = relatedRatings
        self.relatedSymptoms = relatedSymptoms
    }
    
    public func duration() -> TimeInterval? {
        guard let end = endDate else { return nil }
        
        return end.timeIntervalSince(date)
    }
    
    public func chartDisplayEndDate(defaultDuration: TimeInterval) -> Date {
        
        guard let end = endDate else { return date.addingTimeInterval(defaultDuration) }
        
        guard end > date else { return date.addingTimeInterval(defaultDuration) }
        
        return end
    }

    
    public func endDate(defaultDuration: TimeInterval) -> Date {
        return endDate ?? date.addingTimeInterval(defaultDuration)
    }
}

extension DiaryEvent {
    
    static var preview: DiaryEvent {
        DiaryEvent(date: .now.addingTimeInterval(-TimeInterval.random(in: 0...30*24*3600)), category: EventCategory.preview, notes: "Event description/ notes" )
            
    }
    
    static var placeHolder: DiaryEvent {
        DiaryEvent(date: .now, category: EventCategory(name: UserText.term("Placeholder"), color: .primary))
    }

}

