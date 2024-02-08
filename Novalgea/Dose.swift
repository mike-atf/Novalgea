//
//  Dose.swift
//  Novalgea
//
//  Created by aDev on 02/02/2024.
//

import Foundation

public class Dose: NSObject, NSCoding {
    
    public func encode(with coder: NSCoder) {
        coder.encode(Double.self, forKey: "value")
        coder.encode(String.self, forKey: "unit")
    }
    
    public required convenience init?(coder: NSCoder) {
        let unit = coder.decodeObject(forKey: "unit") as! String
        let value = coder.decodeDouble(forKey: "value")
        self.init(unit: unit, value: value)
    }
    
        
    var unit: String
    var value: Double
    var id = UUID().uuidString
    
    init(unit: String, value: Double) {
        self.unit = unit
        self.value = value
    }
    
    
    func userText(long: Bool) -> String {
        
        var unitText = String()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        
        switch self.unit {
        case "ml":
            if self.value <= 1 {
                unitText = long ? "milli-liter" : "ml"
            } else  {
                unitText = long ? "milli-liters" : "ml"
            }
        case "drops":
            if self.value <= 1 {
                unitText = "drop"
            } else  {
                unitText = "drops"
            }

        case "mg":
            if self.value <= 1 {
                unitText = long ? "milligram" : "mg"
            } else  {
                unitText = long ? "milligrams" : "mg"
            }
        case "µg":
            if self.value <= 1 {
                unitText = long ? "microgram" : "mcg"
            } else  {
                unitText = long ? "micrograms" : "mcg"
            }
        case "mcg":
            if self.value <= 1 {
                unitText = long ? "microgram" : "mcg"
            } else  {
                unitText = long ? "micrograms" : "mcg"
            }
        case "gram":
            if self.value <= 1 {
                unitText = "gram"
            } else  {
                unitText = "grams"
            }
        case "portion":
            if self.value <= 1 {
                unitText = "portion"
            } else  {
                unitText = "portions"
            }
        case "mcg_h":
            unitText = long ? "mcg per hour" : "mcg/h"
        default:
            if self.value <= 1 {
                unitText = long ? "milligram" : "mg"
            } else  {
                unitText = long ? "milligrams" : "mg"
            }
       }
        
        return (formatter.string(from: self.value as NSNumber) ?? "-") + " " + unitText
        
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
