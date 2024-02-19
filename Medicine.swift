//
//  Medicine.swift
//  Novalgea
//
//  Created by aDev on 04/02/2024.
//
//

//import UIKit
import SwiftUI
import SwiftData


@Model final class Medicine: Identifiable  {
    
    @Attribute(.transformable(by: "NSSecureUnarchiveFromData")) var alerts: [String]?
    var creatingDevice: String = "Device name"
    var currentStatus: String =  "Current"
    var doses: [Data] = [Data]()
    var drugClass: String = ""
    var effect: String?
    var effectDuration: Double = 0.0
    var endDate: Date?
    @Attribute(.transformable(by: "NSSecureUnarchiveFromData")) var ingredients: [String]?
    var isRegular: Bool = true
    var maxDailyDose: Double?
    var maxSingleDose: Double?
    var name: String = "New medicine" // @Attribute .unique not supported by CloudKit so far
    var notes: String?
    var ratingRemindersOn: Bool = true
    var recommendedDuration: Double?
    var startDate: Date = Date()
    var summaryScore: Double?
    var reviewDates: Data?
    var uuid: UUID = UUID()

    @Relationship(inverse: \PRNMedEvent.medicine) var prnMedEvents: [PRNMedEvent]?
    @Relationship(deleteRule: .nullify ,inverse: \Symptom.treatingMeds) var treatedSymptoms: [Symptom]?
    @Relationship(deleteRule: .nullify ,inverse: \Symptom.causingMeds) var sideEffects: [Symptom]?

    
    public init(name: String = "New medicine \(Date.now)", doses: [Dose], startDate: Date = .now, drugClass: String?=nil, effectDuration: TimeInterval = 24*3600, isRegular: Bool=true, treatedSymptoms: [Symptom]? = []) {
        self.name = name
        self.startDate = startDate
        self.creatingDevice = UIDevice.current.name
        self.drugClass = drugClass ?? ""
        self.uuid = UUID()
        for dose in doses {
            if let doseData = dose.convertToData() {
                self.doses.append(doseData)
            }
        }
        self.effectDuration = effectDuration
        self.isRegular = isRegular
        self.ratingRemindersOn = true
        self.currentStatus = "Current"
        self.treatedSymptoms = treatedSymptoms
        self.reviewDates = nil
    }
    
//    init(creatingDevice: String = "this", currentStatus: String = "current", doses: [Dose], drugClass: String = "class", effect: String? = nil, effectDuration: Double = 24*3600, endDate: Date? = nil, isRegular: Bool = true, maxDailyDose: Double? = nil, maxSingleDose: Double? = nil, name: String = "Sample medicine", notes: String? = nil, ratingRemindersOn: Bool = true, recommendedDuration: Double? = nil, startDate: Date = .now, summaryScore: Double? = nil, uuid: UUID = UUID(), ingredients: [String]? = ["ingredient 1"], alerts: [String]? = ["alert 1"]) {
//        self.creatingDevice = creatingDevice
//        self.currentStatus = currentStatus
//        for dose in doses {
//            if let doseData = dose.convertToData() {
//                self.doses.append(doseData)
//            }
//        }
//        self.drugClass = drugClass
//        self.effect = effect
//        self.effectDuration = effectDuration
//        self.endDate = endDate
//        self.isRegular = isRegular
//        self.maxDailyDose = maxDailyDose
//        self.maxSingleDose = maxSingleDose
//        self.name = name
//        self.notes = notes
//        self.ratingRemindersOn = ratingRemindersOn
//        self.recommendedDuration = recommendedDuration
//        self.startDate = startDate
//        self.summaryScore = summaryScore
//        self.uuid = uuid
//        self.ingredients = ingredients
//        self.alerts = alerts
//    }
}
extension Medicine {
    

    @MainActor
    static var previewContainer: ModelContainer {
        let container = try! ModelContainer(for: Medicine.self,
                                            configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        container.mainContext.insert(Medicine(name: "PCM",doses: [Dose(unit: "mg", value1: 1000)]))
        container.mainContext.insert(Medicine(name: "Sample",doses: [Dose(unit: "mg", value1: 1000)]))
        container.mainContext.insert(Medicine(name: "Ibu",doses: [Dose(unit: "mg", value1: 1000)]))
        container.mainContext.insert(Medicine(name: "Ami",doses: [Dose(unit: "mg", value1: 1000)]))
        
        return container
    }
    
    static var preview: Medicine {
        
        let rndName = ["Paracetamol", "Codeine phosphate", "Naproxen", "Buprenorphine", "Nefopam", "Amitriptyline", "Diazepam", "Ibuprofen", "Gabapentin", "Placebo"].randomElement()!
        return Medicine(name: rndName,doses: [Dose(unit: "mg", value1: 1000)])
            
    }

}
