//
//  Rating+CoreDataProperties.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//
//

import Foundation
import CoreData


extension Rating {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rating> {
        return NSFetchRequest<Rating>(entityName: "Rating")
    }

    @NSManaged public var date: Date?
    @NSManaged public var note: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var vas: Double
    @NSManaged public var ratedSymptom: Symptom?
    @NSManaged public var relatedDiaryEvents: NSSet?
    @NSManaged public var relatedExerciseEvents: ExerciseEvent?
    @NSManaged public var relatedPRNMedEvents: NSSet?

}

// MARK: Generated accessors for relatedDiaryEvents
extension Rating {

    @objc(addRelatedDiaryEventsObject:)
    @NSManaged public func addToRelatedDiaryEvents(_ value: DiaryEvent)

    @objc(removeRelatedDiaryEventsObject:)
    @NSManaged public func removeFromRelatedDiaryEvents(_ value: DiaryEvent)

    @objc(addRelatedDiaryEvents:)
    @NSManaged public func addToRelatedDiaryEvents(_ values: NSSet)

    @objc(removeRelatedDiaryEvents:)
    @NSManaged public func removeFromRelatedDiaryEvents(_ values: NSSet)

}

// MARK: Generated accessors for relatedPRNMedEvents
extension Rating {

    @objc(addRelatedPRNMedEventsObject:)
    @NSManaged public func addToRelatedPRNMedEvents(_ value: PRNMedEvent)

    @objc(removeRelatedPRNMedEventsObject:)
    @NSManaged public func removeFromRelatedPRNMedEvents(_ value: PRNMedEvent)

    @objc(addRelatedPRNMedEvents:)
    @NSManaged public func addToRelatedPRNMedEvents(_ values: NSSet)

    @objc(removeRelatedPRNMedEvents:)
    @NSManaged public func removeFromRelatedPRNMedEvents(_ values: NSSet)

}

extension Rating : Identifiable {

}
