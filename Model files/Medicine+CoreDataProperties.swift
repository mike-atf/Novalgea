//
//  Medicine+CoreDataProperties.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//
//

import Foundation
import CoreData


extension Medicine {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Medicine> {
        return NSFetchRequest<Medicine>(entityName: "Medicine")
    }

    @NSManaged public var alerts: [String]?
    @NSManaged public var creatingDevice: String
    @NSManaged public var currentStatus: String
    @NSManaged public var doses: [Dose]
    @NSManaged public var drugClass: String
    @NSManaged public var effect: String
    @NSManaged public var effectDuration: Double
    @NSManaged public var endDate: Date
    @NSManaged public var ingredients: [String]
    @NSManaged public var isRegular: Bool
    @NSManaged public var maxDailyDose: Double
    @NSManaged public var maxSingleDose: Double
    @NSManaged public var name: String
    @NSManaged public var notes: String
    @NSManaged public var ratingRemindersOn: Bool
    @NSManaged public var recommendedDuration: Double
    @NSManaged public var sideEffects: String
    @NSManaged public var startDate: Date
    @NSManaged public var summaryScore: Double
    @NSManaged public var takingRemindersOn: Bool
    @NSManaged public var uuid: UUID
    @NSManaged public var prnMedEvents: Set<PRNMedEvent>?
    @NSManaged public var treatedSymptoms: Set<Symptom>?

}

// MARK: Generated accessors for prnMedEvents
extension Medicine {

    @objc(addPrnMedEventsObject:)
    @NSManaged public func addToPrnMedEvents(_ value: PRNMedEvent)

    @objc(removePrnMedEventsObject:)
    @NSManaged public func removeFromPrnMedEvents(_ value: PRNMedEvent)

    @objc(addPrnMedEvents:)
    @NSManaged public func addToPrnMedEvents(_ values: NSSet)

    @objc(removePrnMedEvents:)
    @NSManaged public func removeFromPrnMedEvents(_ values: NSSet)

}

// MARK: Generated accessors for treatedSymptoms
extension Medicine {

    @objc(addTreatedSymptomsObject:)
    @NSManaged public func addToTreatedSymptoms(_ value: Symptom)

    @objc(removeTreatedSymptomsObject:)
    @NSManaged public func removeFromTreatedSymptoms(_ value: Symptom)

    @objc(addTreatedSymptoms:)
    @NSManaged public func addToTreatedSymptoms(_ values: NSSet)

    @objc(removeTreatedSymptoms:)
    @NSManaged public func removeFromTreatedSymptoms(_ values: NSSet)

}

extension Medicine : Identifiable {

}

enum MedicineEffect: String, CaseIterable {
    case good = "good.effect"
    case moderate = "moderate.effect"
    case minimal = "minimal.effect"
    case none = "no.effect"
}

enum MedicineSideffect: String, CaseIterable {
    case strong = "strong.sideEffects"
    case moderate = "moderate.sideEffects"
    case minimal = "minimal.sideEffects"
    case none = "no.sideEffects"
}

