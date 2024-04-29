//
//  EventCategory.swift
//  Novalgea
//
//  Created by aDev on 26/03/2024.
//

import SwiftUI
import SwiftData

@Model class EventCategory: Identifiable, Hashable {
    
    var name = String()
    var relatedDiaryEvents: [DiaryEvent]? = []
    var symbol: String = "⚪️"
//    var colorModel: [CGFloat]?
    var colorName: String?
    var uuid: UUID = UUID()
    
    init(name: String, relatedDiaryEvents: [DiaryEvent]? = [], symbol: String = "⚪️", color: Color?=nil, colorName: String?=nil) {
        self.name = name
        self.symbol = symbol
        self.relatedDiaryEvents = relatedDiaryEvents
        
        if colorName != nil {
            self.colorName = colorName!
        } else {
            for key in ColorScheme.symptomColors.keys {
                if color == ColorScheme.symptomColors[key] {
                    self.colorName = key
                }
            }
        }
    }
    
    public func color() -> Color {
        
        guard let colorName else { return Color.primary }
        
        return Color(UIColor(named: colorName) ?? UIColor.label)
    }
    
    public func setNewColor(color: Color) {
        
        for key in ColorScheme.categoryColors.keys {
            if color == ColorScheme.categoryColors[key] {
                self.colorName = key
            }
        }
    }


    
}

extension EventCategory {
    
    static var preview: EventCategory {        
        EventCategory(name: "Preview event category", symbol: SymbolScheme.eventCategorySymbols.randomElement()!, color: ColorScheme.eventCategoryColorsArray.randomElement()!)
    }
    
    static var addNew: EventCategory {
        EventCategory(name: UserText.term("Add new"), symbol: SymbolScheme.eventCategorySymbols.randomElement()!, color: .primary)
    }
    
    static var placeholder: EventCategory {
        EventCategory(name: UserText.term("Placeholder"), symbol: SymbolScheme.eventCategorySymbols.randomElement()!, color: .primary)
    }

    

}

