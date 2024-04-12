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
    var symbol: String = "⚪️"
    var uuid: UUID = UUID()
    
    init(name: String, relatedDiaryEvents: [DiaryEvent]? = [], symbol: String = "⚪️"
) {
        self.name = name
        self.symbol = symbol
        self.relatedDiaryEvents = relatedDiaryEvents
    }

    
}

extension EventCategory {
    
    static var preview: EventCategory {
        
        EventCategory(name: "Preview event category", symbol: eventSymbolOptions.randomElement()!)
    }

}

