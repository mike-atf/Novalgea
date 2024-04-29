//
//  Dose.swift
//  Novalgea
//
//  Created by aDev on 02/02/2024.
//

import Foundation

struct Dose {
        
    var time: Date
    var reminderIsOn: Bool
    var unit: String
    var value1: Double
    var value2: Double?
    var id = UUID().uuidString
    
    init(time: Date = .now, reminderIsOn: Bool = true ,unit: String, value1: Double, value2: Double?=nil) {
        self.time = time
        self.reminderIsOn = reminderIsOn
        self.unit = unit
        self.value1 = value1
        self.value2 = value2
    }
    
    public func convertToData() -> Data? {
        
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
    
    /// 'long' results in longer unit descriptions such as 'milli-liter' rather than 'ml' for long=false
    func userText(long: Bool) -> String {
        
        var unitText = String()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        switch self.unit {
        case "ml":
            if self.value1 <= 1 {
                unitText = long ? "milli-liter" : "ml"
            } else  {
                unitText = long ? "milli-liters" : "ml"
            }
        case "drops":
            if self.value1 <= 1 {
                unitText = "drop"
            } else  {
                unitText = "drops"
            }

        case "mg":
            if self.value1 <= 1 {
                unitText = long ? "milligram" : "mg"
            } else  {
                unitText = long ? "milligrams" : "mg"
            }
        case "µg":
            if self.value1 <= 1 {
                unitText = long ? "microgram" : "mcg"
            } else  {
                unitText = long ? "micrograms" : "mcg"
            }
        case "mcg":
            if self.value1 <= 1 {
                unitText = long ? "microgram" : "mcg"
            } else  {
                unitText = long ? "micrograms" : "mcg"
            }
        case "gram":
            if self.value1 <= 1 {
                unitText = "gram"
            } else  {
                unitText = "grams"
            }
        case "portion":
            if self.value1 <= 1 {
                unitText = "portion"
            } else  {
                unitText = "portions"
            }
        case "mcg_h":
            unitText = long ? "mcg per hour" : "mcg/h"
        default:
            if self.value1 <= 1 {
                unitText = long ? "milligram" : "mg"
            } else  {
                unitText = long ? "milligrams" : "mg"
            }
       }
        
        return (formatter.string(from: self.value1 as NSNumber) ?? "-") + " " + unitText
        
    }
    
}

enum DoseUnit: String, Codable {
    case ml = "ml"
    case drops = "drops"
    case mg = "mg"
    case µg = "µg"
    case mcg = "mcg"
    case gram = "gram"
    case portion = "portion"
    case mcg_h = "mcg/h"
}
