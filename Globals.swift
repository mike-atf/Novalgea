//
//  Globals.swift
//  Novalgea
//
//  Created by aDev on 29/02/2024.
//

import SwiftUI

enum DisplayTimeOption: String, CaseIterable, Identifiable {
    
    
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case quarter = "Quarter"
    case year = "Year"
    
    var id: String { rawValue }
    
    var timeValue: TimeInterval {
        switch self {
        case.day: return 24*3600
        case .week: return 7*24*3600
        case .month: return 365*24*3600/12
        case .quarter: return 365*24*3600/4
        case .year: return 365*24*3600
        }
    }
}

enum ChangeDisplayTime {
    case forwards
    case backwards
}

enum BackdatingTimeOptions: String, CaseIterable, Identifiable {
    case isNow = "now"
    case halfHourAgo = "30 min ago"
    case oneHourAgo = "one hour ago"
    case twoHoursAgo = "two hours ago"
    case custom = "custom date"
    var id: String { rawValue }
}

enum Position {
    case leading
    case trailing
}

enum SymptomType: String, CaseIterable, Identifiable {
    case symptom = "Symptom"
    case sideEffect = "Side effect"
    var id: String { rawValue }
}

struct ColorScheme {
    static let gradientColors = [.white, Color(red: 251/255, green: 247/255, blue: 118/255), Color(red: 255/255, green: 161/255, blue: 34/255), Color(red: 151/255, green: 60/255, blue: 56/255)]
    static let medicineColorsArray = [Color(UIColor(named: "m0")!), Color(UIColor(named: "m1")!), Color(UIColor(named: "m2")!), Color(UIColor(named: "m3")!), Color(UIColor(named: "m4")!), Color(UIColor(named: "m5")!)]
    static let symptomColorsArray = [Color(UIColor(named: "s0")!), Color(UIColor(named: "s1")!), Color(UIColor(named: "s2")!), Color(UIColor(named: "s3")!), Color(UIColor(named: "s4")!), Color(UIColor(named: "s5")!)]
    static let eventCategoryColorsArray = [Color(UIColor(named: "e0")!), Color(UIColor(named: "e1")!), Color(UIColor(named: "e2")!), Color(UIColor(named: "e3")!), Color(UIColor(named: "e4")!), Color(UIColor(named: "e5")!)]
    
    static let symptomColors: [String:Color] = {
        
        var dictionary = [String: Color]()
        var index = 0
        for color in symptomColorsArray {
            dictionary["s\(index)"] = color
            index += 1
        }
        return dictionary
    }()
    
    static let categoryColors: [String:Color] = {
        
        var dictionary = [String: Color]()
        var index = 0
        for color in eventCategoryColorsArray {
            dictionary["e\(index)"] = color
            index += 1
        }
        return dictionary
    }()
    
    static let medicineColors: [String:Color] = {
        
        var dictionary = [String: Color]()
        var index = 0
        for color in medicineColorsArray {
            dictionary["m\(index)"] = color
            index += 1
        }
        return dictionary
    }()

}

struct SymbolScheme {
    static let eventCategorySymbols = ["🤍","🆘","🛑","⚠️","💤","⚪️","⬜️","🔶","🛄","🦠","🛀","💊","🩻","🌦️"]
}
