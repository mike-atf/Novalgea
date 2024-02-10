//
//  PRNMedEvent.swift
//  Novalgea
//
//  Created by aDev on 04/02/2024.
//
//

import Foundation
import SwiftData


@Model class PRNMedEvent: Identifiable  {
    var endDate: Date = Date()
    var startDate: Date = Date()
    var uuid: UUID = UUID()
    var medicine: Medicine?
    
    @Relationship(inverse: \Rating.relatedPRNMedEvents) var relatedRatings: [Rating]?
    
    init(endDate: Date? = nil, startDate: Date? = nil, uuid: UUID = UUID(), medicine: Medicine, relatedRatings: [Rating]? = []) {
        self.startDate = startDate ?? .now
        self.endDate = endDate ?? .now.addingTimeInterval(medicine.effectDuration)
        self.uuid = uuid
        self.medicine = medicine
        self.relatedRatings = relatedRatings
    }
}

extension PRNMedEvent {
    
    static var preview: PRNMedEvent {
        
        let rndName = ["Paracetamol", "Codeine phosphate", "Naproxen", "Buprenorphine", "Nefopam", "Amitriptyline", "Diazepam", "Ibuprofen", "Gabapentin", "Placebo"].randomElement()!
        let rndMedicine =  Medicine(name: rndName, dose: Dose(unit: "mg", value1: 100.0))
        return PRNMedEvent(medicine: rndMedicine)
    }

}

