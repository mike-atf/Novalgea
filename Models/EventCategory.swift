//
//  EventCategory.swift
//  Novalgea
//
//  Created by aDev on 26/03/2024.
//

import Foundation
import SwiftData

@Model class EventCategory: Identifiable, Hashable {
    
    var name = String()
    var relatedDiaryEvents: [DiaryEvent]? = []
    var uuid: UUID = UUID()
    
    init(name: String, relatedDiaryEvents: [DiaryEvent]? = []) {
        self.name = name
        self.relatedDiaryEvents = relatedDiaryEvents
    }

    
}

extension EventCategory {
    
    static var preview: EventCategory {
        
        EventCategory(name: "Preview event category")
    }

}

