//
//  Symptom+CoreDataProperties.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//
//

import Foundation
import CoreData


extension Symptom {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Symptom> {
        return NSFetchRequest<Symptom>(entityName: "Symptom")
    }

    @NSManaged public var averages: [Double]?
    @NSManaged public var creatingDevice: String?
    @NSManaged public var maxVAS: Double
    @NSManaged public var minVAS: Double
    @NSManaged public var name: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var diaryEvents: NSSet?
    @NSManaged public var ratingEvents: NSSet?
    @NSManaged public var treatingMeds: NSSet?

}

// MARK: Generated accessors for diaryEvents
extension Symptom {

    @objc(addDiaryEventsObject:)
    @NSManaged public func addToDiaryEvents(_ value: DiaryEvent)

    @objc(removeDiaryEventsObject:)
    @NSManaged public func removeFromDiaryEvents(_ value: DiaryEvent)

    @objc(addDiaryEvents:)
    @NSManaged public func addToDiaryEvents(_ values: NSSet)

    @objc(removeDiaryEvents:)
    @NSManaged public func removeFromDiaryEvents(_ values: NSSet)

}

// MARK: Generated accessors for ratingEvents
extension Symptom {

    @objc(addRatingEventsObject:)
    @NSManaged public func addToRatingEvents(_ value: Rating)

    @objc(removeRatingEventsObject:)
    @NSManaged public func removeFromRatingEvents(_ value: Rating)

    @objc(addRatingEvents:)
    @NSManaged public func addToRatingEvents(_ values: NSSet)

    @objc(removeRatingEvents:)
    @NSManaged public func removeFromRatingEvents(_ values: NSSet)

}

// MARK: Generated accessors for treatingMeds
extension Symptom {

    @objc(addTreatingMedsObject:)
    @NSManaged public func addToTreatingMeds(_ value: Medicine)

    @objc(removeTreatingMedsObject:)
    @NSManaged public func removeFromTreatingMeds(_ value: Medicine)

    @objc(addTreatingMeds:)
    @NSManaged public func addToTreatingMeds(_ values: NSSet)

    @objc(removeTreatingMeds:)
    @NSManaged public func removeFromTreatingMeds(_ values: NSSet)

}

extension Symptom : Identifiable {

}
