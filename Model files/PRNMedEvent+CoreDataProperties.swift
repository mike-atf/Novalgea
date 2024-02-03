//
//  PRNMedEvent+CoreDataProperties.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//
//

import Foundation
import CoreData


extension PRNMedEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PRNMedEvent> {
        return NSFetchRequest<PRNMedEvent>(entityName: "PRNMedEvent")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var uuid: UUID?
    @NSManaged public var medicine: Medicine?
    @NSManaged public var relatedRatings: NSSet?

}

// MARK: Generated accessors for relatedRatings
extension PRNMedEvent {

    @objc(addRelatedRatingsObject:)
    @NSManaged public func addToRelatedRatings(_ value: Rating)

    @objc(removeRelatedRatingsObject:)
    @NSManaged public func removeFromRelatedRatings(_ value: Rating)

    @objc(addRelatedRatings:)
    @NSManaged public func addToRelatedRatings(_ values: NSSet)

    @objc(removeRelatedRatings:)
    @NSManaged public func removeFromRelatedRatings(_ values: NSSet)

}

extension PRNMedEvent : Identifiable {

}
