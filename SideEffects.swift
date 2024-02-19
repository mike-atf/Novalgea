//
//  SideEffects.swift
//  Novalgea
//
//  Created by aDev on 17/02/2024.
//

import Foundation

struct SideEffect {
    
    var name: String
    var intensity: String
    var startDate: Date
    var endDate: Date?
//    var medicine: Medicine
    
    init(name: String, intensity: String, startDate: Date = .now, endDate: Date? = nil) { //medicine: Medicine ,
        self.name = name
        self.intensity = intensity
        self.startDate = startDate
        self.endDate = endDate
//        self.medicine = medicine
    }
    
//    func encode(with coder: NSCoder) {
//        coder.encode(name, forKey: "name")
//        coder.encode(intensity, forKey: "intensity")
//        coder.encode(startDate, forKey: "startDate")
//        if let date = endDate {
//            coder.encode(date, forKey: "endDate")
//        }
//    }
//    
//    required convenience init?(coder: NSCoder) {
//        guard let sdate = coder.decodeObject(forKey: "startDate") as? Date,
//            let dName = coder.decodeObject(forKey: "name") as? String,
//            let dIntensity = coder.decodeObject(forKey: "intensity") as? String,
//              let med = coder.dec
//        else { return nil }
//        
//        let edate = coder.decodeObject(forKey: "endDate") as? Date
//        
//        self.init(name: dName, intensity: dIntensity, startDate: sdate, endDate: edate)
//    }
    

}
//
//extension SideEffect {
//    
//    static var preview: SideEffect {
//        
//        SideEffect(name: "a side effect", intensity: "moderate", medicine: Medicine(dose: Dose(unit: "mg", value1: 0.0)))
//    }
//
//}

