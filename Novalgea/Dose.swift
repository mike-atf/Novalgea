//
//  Dose.swift
//  Novalgea
//
//  Created by aDev on 02/02/2024.
//

import Foundation

class Dose: Codable {
        
    var unit: DoseUnit
    var value: Double
    var id = UUID().uuidString
    
    init(unit: DoseUnit, value: Double) {
        self.unit = unit
        self.value = value
    }
    
    func userText(long: Bool) -> String {
        
        var unitText = String()
        
        var formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        switch self.unit {
        case .ml:
            if self.value <= 1 {
                unitText = long ? "milli-liter" : "ml"
            } else  {
                unitText = long ? "milli-liters" : "ml"
            }
        case .drops:
            if self.value <= 1 {
                unitText = "drop"
            } else  {
                unitText = "drops"
            }

        case .mg:
            if self.value <= 1 {
                unitText = long ? "milligram" : "mg"
            } else  {
                unitText = long ? "milligrams" : "mg"
            }
        case .µg:
            if self.value <= 1 {
                unitText = long ? "microgram" : "mcg"
            } else  {
                unitText = long ? "micrograms" : "mcg"
            }
        case .mcg:
            if self.value <= 1 {
                unitText = long ? "microgram" : "mcg"
            } else  {
                unitText = long ? "micrograms" : "mcg"
            }
        case .gram:
            if self.value <= 1 {
                unitText = "gram"
            } else  {
                unitText = "grams"
            }
        case .portion:
            if self.value <= 1 {
                unitText = "portion"
            } else  {
                unitText = "portions"
            }
        case .mcg_h:
            unitText = long ? "mcg per hour" : "mcg/h"
       }
        
        return (formatter.string(from: self.value as NSNumber) ?? "-") + " " + unitText
        
    }
    
}

enum DoseUnit: Codable {
    case ml
    case drops
    case mg
    case µg
    case mcg
    case gram
    case portion
    case mcg_h
}
