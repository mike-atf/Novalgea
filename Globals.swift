//
//  Globals.swift
//  Novalgea
//
//  Created by aDev on 29/02/2024.
//

import Foundation

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
