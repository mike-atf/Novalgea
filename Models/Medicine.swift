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

    @Relationship(deleteRule: .cascade, inverse: \MedicineEvent.medicine) var medEvents: [MedicineEvent]?
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

    public func dosesTaken(from:Date, to: Date) -> Int {
        
        if isRegular {
            if startDate > to { return 0 }
            else if endDate ?? Date.distantFuture < from { return 0 }
            
            let startCountingDate = max(startDate, from)
            let endCountingDate = min(endDate!, to)
            
            let interval = endCountingDate.timeIntervalSince(startCountingDate)
            
            return Int(interval / effectDuration)
            
        } else {
            guard medEvents != nil else { return 0 }
            let inDateEvents = medEvents!.filter({ event in
                if event.endDate! < from { return false }
                else if event.startDate > to { return false }
                else { return true }
            })
            
            return inDateEvents.count
        }
    }


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
