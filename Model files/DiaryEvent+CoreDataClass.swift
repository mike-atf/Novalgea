//
//  DiaryEvent+CoreDataClass.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//
//

import Foundation
import CoreData


public class DiaryEvent: NSManagedObject {
    
    public func setDefaults() {
        self.date = Date()
        self.category = UserDefaults.standard.string(forKey: User_Default_Keys.selectedSymptom.rawValue) ?? defaultSymptom
        self.uuid = UUID()
        self.notes = String()
    }


}
