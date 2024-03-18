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

enum Position {
    case leading
    case trailing
}

let gradientRed = Color(red: 151/255, green: 60/255, blue: 56/255)
let angulargradient = AngularGradient(colors: [.white, Color(red: 251/255, green: 247/255, blue: 118/255), Color(red: 255/255, green: 161/255, blue: 34/255), Color(red: 151/255, green: 60/255, blue: 56/255)], center: .center, startAngle: .degrees(270), endAngle: .degrees(-90))
