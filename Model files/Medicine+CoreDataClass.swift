//
//  Medicine+CoreDataClass.swift
//  Novalgea
//
//  Created by aDev on 03/02/2024.
//
//

import UIKit
import CoreData


public class Medicine: NSManagedObject {
    
    public func setDefaults() {
        name = NSLocalizedString("Meds.newMedicine", comment: "")
        startDate = Date()
        currentStatus = NSLocalizedString("Meds.current", comment: "")
        doses = [Dose(unit: DoseUnit.mg, value: 1.0)]
        effectDuration = 24*3600
        creatingDevice = UIDevice.current.name
        isRegular = true
        uuid = UUID()
        summaryScore = -1.0
    }


}
