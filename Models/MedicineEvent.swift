//
//  MedicineEvent.swift
//  Novalgea
//
//  Created by aDev on 06/03/2024.
//

import Foundation
import SwiftData

@Model class MedicineEvent: Identifiable  {
    var endDate: Date? // nil-value should be sufficient to designate regular drug that has not been discontinued
    var startDate: Date = Date()
    var uuid: UUID = UUID()
    var medicine: Medicine?
    
    @Relationship(deleteRule: .nullify, inverse: \Rating.relatedMedEvents) var relatedRatings: [Rating]?
    
    init(endDate: Date? = nil, startDate: Date = .now, uuid: UUID = UUID(), medicine: Medicine, relatedRatings: [Rating]? = []) {
        self.startDate = startDate
        self.endDate = endDate ?? .now.addingTimeInterval(medicine.effectDuration)
        self.uuid = uuid
        self.medicine = medicine
        self.relatedRatings = relatedRatings
    }
    
    public func endDateForChart(chartEndDate: Date) -> Date {
        return endDate ?? chartEndDate.addingTimeInterval(24*3600)
    }
    
}

extension MedicineEvent {
    
    static var preview: MedicineEvent {
        
        let rndName = ["Paracetamol", "Codeine phosphate", "Naproxen", "Buprenorphine", "Nefopam", "Amitriptyline", "Diazepam", "Ibuprofen", "Gabapentin", "Placebo"].randomElement()!
        let rndMedicine =  Medicine(name: rndName,doses: [Dose(unit: "mg", value1: 1000)])
        return MedicineEvent(medicine: rndMedicine)
    }

}

