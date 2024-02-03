//
//  DiaryEvent+CoreDataProperties.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//
//

import Foundation
import CoreData


extension DiaryEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DiaryEvent> {
        return NSFetchRequest<DiaryEvent>(entityName: "DiaryEvent")
    }

    @NSManaged public var category: String
    @NSManaged public var date: Date
    @NSManaged public var endDate: Date?
    @NSManaged public var notes: String?
    @NSManaged public var uuid: UUID
    @NSManaged public var relatedRatings: Set<Rating>?
    @NSManaged public var relatedSymptoms: Set<Symptom>?

}

// MARK: Generated accessors for relatedRatings
extension DiaryEvent {

    @objc(addRelatedRatingsObject:)
    @NSManaged public func addToRelatedRatings(_ value: Rating)

    @objc(removeRelatedRatingsObject:)
    @NSManaged public func removeFromRelatedRatings(_ value: Rating)

    @objc(addRelatedRatings:)
    @NSManaged public func addToRelatedRatings(_ values: NSSet)

    @objc(removeRelatedRatings:)
    @NSManaged public func removeFromRelatedRatings(_ values: NSSet)

}

// MARK: Generated accessors for relatedSymptoms
extension DiaryEvent {

    @objc(addRelatedSymptomsObject:)
    @NSManaged public func addToRelatedSymptoms(_ value: Symptom)

    @objc(removeRelatedSymptomsObject:)
    @NSManaged public func removeFromRelatedSymptoms(_ value: Symptom)

    @objc(addRelatedSymptoms:)
    @NSManaged public func addToRelatedSymptoms(_ values: NSSet)

    @objc(removeRelatedSymptoms:)
    @NSManaged public func removeFromRelatedSymptoms(_ values: NSSet)

}

extension DiaryEvent : Identifiable {

}
