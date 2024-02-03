//
//  InternalError+CoreDataProperties.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//
//

import Foundation
import CoreData


extension InternalError {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InternalError> {
        return NSFetchRequest<InternalError>(entityName: "InternalError")
    }

    @NSManaged public var dates: [Date]
    @NSManaged public var count: Int64
    @NSManaged public var file: String
    @NSManaged public var function: String
    @NSManaged public var osError: String?
    @NSManaged public var appError: String?

}

extension InternalError : Identifiable {

}
