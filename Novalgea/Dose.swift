//
//  Dose.swift
//  Novalgea
//
//  Created by aDev on 02/02/2024.
//

import Foundation

struct Dose { //: NSObject, NSCoding
    
//    public func encode(with coder: NSCoder) {
//        coder.encode(Double.self, forKey: "value1")
//        coder.encode(Double?.self, forKey: "value2")
//        coder.encode(String.self, forKey: "unit")
//        coder.encode(Date.self, forKey: "time")
//        coder.encode(Bool.self, forKey: "reminderIsOn")
//   }
//    
//    public required convenience init?(coder: NSCoder) {
//        let time = coder.decodeObject(forKey: "time") as! Date
//        let reminderisOn = coder.decodeBool(forKey: "reminderIsOn")
//        let unit = coder.decodeObject(forKey: "unit") as! String
//        let value1 = coder.decodeDouble(forKey: "value1")
//        let value2 = coder.decodeDouble(forKey: "value2")
//        self.init(time: time, reminderIsOn: reminderisOn ,unit: unit, value1: value1, value2: value2)
//    }
    
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
