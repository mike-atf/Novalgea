//
//  Symptom.swift
//  Novalgea
//
//  Created by aDev on 04/02/2024.
//
//

import Foundation
import SwiftData


@Model class Symptom: Identifiable  {
    @Attribute(.transformable(by: "NSSecureUnarchiveFromData")) var averages: [Double]?
    var creatingDevice: String = "Device"
    var maxVAS: Double? = 0.0
    var minVAS: Double? = 0.0
    var name: String = "Default symptom"
    var uuid: UUID = UUID()
    var diaryEvents: [DiaryEvent]?

    @Relationship(deleteRule: .cascade, inverse: \Rating.ratedSymptom) var ratingEvents: [Rating]?
    @Relationship(inverse: \Medicine.treatedSymptoms) var treatingMeds: [Medicine]?
    
    init(averages: [Double]? = nil, creatingDevice: String, maxVAS: Double? = nil, minVAS: Double? = nil, name: String, uuid: UUID = UUID(), diaryEvents: [DiaryEvent]? = [], ratingEvents: [Rating]? = [], treatingMeds: [Medicine]? = []) {
        
        self.averages = averages
        self.creatingDevice = creatingDevice
        self.maxVAS = maxVAS
        self.minVAS = minVAS
        self.name = name
        self.uuid = uuid
        self.diaryEvents = diaryEvents
        self.ratingEvents = ratingEvents
        self.treatingMeds = treatingMeds
    }
}


extension Symptom {
    
    static var preview: Symptom {
        
        Symptom(creatingDevice: "Sample device", name: "Pain intensity")
    }

}
