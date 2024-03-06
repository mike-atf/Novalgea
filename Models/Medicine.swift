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

    @Relationship(deleteRule: .cascade, inverse: \MedicineEvent.medicine) var prnMedEvents: [MedicineEvent]?
    @Relationship(deleteRule: .nullify ,inverse: \Symptom.treatingMeds) var treatedSymptoms: [Symptom]?
    @Relationship(deleteRule: .cascade ,inverse: \Symptom.causingMeds) var sideEffects: [Symptom]?
    @Relationship(deleteRule: .cascade ,inverse: \Rating.ratedMedicine) var effectRatings: [Rating]?
    
    public init(name: String = "New medicine \(Date.now)", doses: [Dose], startDate: Date = .now, endDate: Date?=nil,drugClass: String?=nil, effectDuration: TimeInterval = 24*3600, isRegular: Bool=true, treatedSymptoms: [Symptom]? = [], effectRatings: [Rating]? = [], creatingDevice: String?=nil) {
        self.name = name
        self.startDate = startDate
        self.creatingDevice = creatingDevice ?? UIDevice.current.name
        self.drugClass = drugClass ?? ""
        self.uuid = UUID()
        self.doses = doses.convertToData()
        self.effectDuration = effectDuration
        self.isRegular = isRegular
        self.ratingRemindersOn = true
        self.currentStatus = "Current"
        self.treatedSymptoms = treatedSymptoms
        self.reviewDates = nil
        self.effectRatings = effectRatings
    }
    
//    public func copy() -> Medicine {
//        
//        var copy = Medicine(doses: self.doses.convertToDoses() ?? [Dose(unit: "mg", value1: 0.0)])
//        copy.name = self.name
//        copy.startDate = self.startDate
//        copy.endDate = self.endDate
//        copy.effectDuration = self.effectDuration
//        copy.isRegular = self.isRegular
//        copy.drugClass = self.drugClass
//        copy.creatingDevice = self.creatingDevice
//        copy.ratingRemindersOn = self.ratingRemindersOn
//        copy.currentStatus = self.currentStatus
//        copy.reviewDates = self.reviewDates
//        copy.notes = self.notes
//        copy.maxDailyDose = self.maxDailyDose
//        copy.maxSingleDose = self.maxSingleDose
//        copy.effectRatings = self.effectRatings
//        copy.prnMedEvents = self.prnMedEvents
//        copy.treatedSymptoms = self.treatedSymptoms
//        copy.sideEffects = self.sideEffects
//        
//        return copy
//    }
    
//    public func copy(original: Medicine) {
//        self.name = original.name
//        self.startDate = original.startDate
//        self.endDate = original.endDate
//        self.effectDuration = original.effectDuration
//        self.isRegular = original.isRegular
//        self.drugClass = original.drugClass
//        self.creatingDevice = original.creatingDevice
//        self.ratingRemindersOn = original.ratingRemindersOn
//        self.currentStatus = original.currentStatus
//        self.reviewDates = original.reviewDates
//        self.notes = original.notes
//        self.maxDailyDose = original.maxDailyDose
//        self.maxSingleDose = original.maxSingleDose
//        self.effectRatings = original.effectRatings
//        self.prnMedEvents = original.prnMedEvents
//        self.treatedSymptoms = original.treatedSymptoms
//        self.sideEffects = original.sideEffects
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
