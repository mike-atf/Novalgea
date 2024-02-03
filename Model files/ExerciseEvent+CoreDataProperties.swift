//
//  ExerciseEvent+CoreDataProperties.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//
//

import Foundation
import CoreData


extension ExerciseEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExerciseEvent> {
        return NSFetchRequest<ExerciseEvent>(entityName: "ExerciseEvent")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var exerciseName: String
    @NSManaged public var startDate: Date
    @NSManaged public var unit: String
    @NSManaged public var uuid: UUID
    @NSManaged public var value: Double
    @NSManaged public var relatedRatings: Set<Rating>?

}

// MARK: Generated accessors for relatedRatings
extension ExerciseEvent {

    @objc(addRelatedRatingsObject:)
    @NSManaged public func addToRelatedRatings(_ value: Rating)

    @objc(removeRelatedRatingsObject:)
    @NSManaged public func removeFromRelatedRatings(_ value: Rating)

    @objc(addRelatedRatings:)
    @NSManaged public func addToRelatedRatings(_ values: NSSet)

    @objc(removeRelatedRatings:)
    @NSManaged public func removeFromRelatedRatings(_ values: NSSet)

}

extension ExerciseEvent : Identifiable {

}
