//
//  Symptom.swift
//  Novalgea
//
//  Created by aDev on 04/02/2024.
//
//

import Foundation
import SwiftData


@Model final class Symptom: Identifiable  {
    
    var name: String = "Default symptom"
    var type: String = "Symptom" // the other option is Side effect
    @Attribute(.transformable(by: "NSSecureUnarchiveFromData")) var averages: [Double]?
    var creatingDevice: String = "Device"
    var maxVAS: Double = 10.0
    var minVAS: Double = 0.0
    var uuid: UUID = UUID()
    
    var diaryEvents: [DiaryEvent]?
    @Relationship(deleteRule: .cascade, inverse: \Rating.ratedSymptom) var ratingEvents: [Rating]?
    var treatingMeds: [Medicine]?
    var causingMeds: [Medicine]?
    
    init(name: String, type: String ,averages: [Double]? = nil, creatingDevice: String, maxVAS: Double = 10, minVAS: Double = 0, uuid: UUID = UUID(), diaryEvents: [DiaryEvent]? = [], ratingEvents: [Rating]? = [], treatingMeds: [Medicine]? = [], causingMeds: [Medicine]? = []) {
        
        self.averages = averages
        self.creatingDevice = creatingDevice
        self.maxVAS = maxVAS
        self.minVAS = minVAS
        self.name = name
        self.uuid = uuid
        self.diaryEvents = diaryEvents
        self.ratingEvents = ratingEvents
        self.treatingMeds = treatingMeds
        self.causingMeds = causingMeds
    }
}


extension Symptom {
    
    static var preview: Symptom {
        
        Symptom(name: "Sample symptom", type: "Symptom", creatingDevice: "Sample device")
    }

}
