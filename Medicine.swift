//
//  Medicine.swift
//  Novalgea
//
//  Created by aDev on 04/02/2024.
//
//

import UIKit
import SwiftData


@Model final class Medicine: Identifiable  {
    
//    @Attribute(.transformable(by: "NSSecureUnarchiveFromData")) var alerts: [String]?
    var creatingDevice: String = "Device name"
    var currentStatus: String =  "Current"
//    @Attribute(.transformable(by: "NSSecureUnarchiveFromData")) var doses: [Dose]?
    var drugClass: String = ""
    var effect: String?
    var effectDuration: Double = 0.0
    var endDate: Date?
//    @Attribute(.transformable(by: "NSSecureUnarchiveFromData")) var ingredients: [String]?
    var isRegular: Bool = true
    var maxDailyDose: Double?
    var maxSingleDose: Double?
    var name: String = "New medicine" // @Attribute .unique not supported by CloudKit so far
    var notes: String?
    var ratingRemindersOn: Bool = true
    var recommendedDuration: Double?
    var sideEffects: String?
    var startDate: Date = Date()
    var summaryScore: Double?
    var takingRemindersOn: Bool = true
    var uuid: UUID = UUID()
        
//    @Relationship(inverse: \PRNMedEvent.medicine) var prnMedEvents: [PRNMedEvent]?
//    var treatedSymptoms: [Symptom]?
    
    public init(name: String = "New medicine \(Date.now)", dose: Dose, startDate: Date = .now, drugClass: String?=nil, effectDuration: TimeInterval = 24*3600, isRegular: Bool=true) {
//    public init(name: String = "New medicine \(Date.now)", startDate: Date = .now, drugClass: String?=nil, effectDuration: TimeInterval = 24*3600, isRegular: Bool=true) {
        self.name = name
        self.startDate = startDate
        self.creatingDevice = UIDevice.current.name
        self.drugClass = drugClass ?? ""
        self.uuid = UUID()
//        self.doses = [dose]
        
        self.effectDuration = effectDuration
        self.isRegular = isRegular
        self.takingRemindersOn = true
        self.ratingRemindersOn = true
        self.currentStatus = "Current"
        
    }
    
}

extension Medicine {
    

    @MainActor
    static var preview: ModelContainer {
        let container = try! ModelContainer(for: Medicine.self,
                                            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        container.mainContext.insert(Medicine(name: "PCM",dose: Dose(unit: "mg", value: 1000)))
        container.mainContext.insert(Medicine(name: "Sample",dose: Dose(unit: "mg", value: 1)))
        container.mainContext.insert(Medicine(name: "Ibu",dose: Dose(unit: "mg", value: 200)))
        container.mainContext.insert(Medicine(name: "Ami",dose: Dose(unit: "mg", value: 10)))
        
        return container
    }
    
    static var previewSample: Medicine {
        
        Medicine(name: "Sample medicine \(Date())", dose: Dose(unit: "mg", value: 100.0))

//        Medicine(name: ["Paracetamol", "Codeine phosphate", "Naproxen", "Buprenorphine", "Nefopam", "Amitriptyline", "Diazepam", "Ibuprofen", "Gabapentin", "Placebo"].randomElement()!)
            
    }

}
