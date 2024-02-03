//
//  Symptom+CoreDataClass.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//
//

import UIKit
import CoreData


public class Symptom: NSManagedObject {
    
    public func setDefaults() {
        name = UserDefaults.standard.string(forKey: User_Default_Keys.selectedSymptom.rawValue) ?? defaultSymptom
        maxVAS = 10.0
        minVAS = 0.0
        uuid = UUID()
        averages = [0.0]
        creatingDevice = UIDevice.current.name

    }


}
