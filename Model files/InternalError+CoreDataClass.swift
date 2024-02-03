//
//  InternalError+CoreDataClass.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//
//

import Foundation
import CoreData

@objc(InternalError)
public class InternalError: NSManagedObject {
    
    func fromNewError(error: IntError) {
        self.dates = [Date()]
        self.file = error.file
        self.function = error.function
        self.appError = error.appError
        self.osError = error.osError
        self.count = 1
    }

}
