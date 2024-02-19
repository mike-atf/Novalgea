//
//  Alogea_Drug.swift
//  Novalgea
//
//  Created by aDev on 15/02/2024.
//

import Foundation
import SwiftData
import OSLog

class Alogea_Drug {
    
     var dosagePlanDrug: String? // contains the drugID of the original med for a dosageIncreasePlan
     var treatedSymptoms: NSData?
     var maxDailyDoses: NSData?
     var maxSingleDoses: NSData?
     var singleTabletDoses: NSData?
     var attribute1: NSData? // used as Bool for ratingRemindersOn for regular drugs
     var attribute2: NSData? // store recommended duration as TimeInterval
     var attribute3: NSData? // used for ReviewDates struct
     var classes: NSData?
     var doses: NSData
     var doseUnit: String
     var drugID: String
     var effectiveness: String?
     var endDate: Date?
     var frequency: Double
     var ingredients: NSData?
     var isCurrent: String
     var name: String
     var notes: String?
     var regularly: Bool
     var reminders: NSData?
     var sideEffects: NSData?
     var startDate: Date
     var tablets: NSData?
     var urid: String
     var uuid: UUID
     var effectDuration: Double
    
    init(dosagePlanDrug: String? = nil, treatedSymptoms: NSData? = nil, maxDailyDoses: NSData? = nil, maxSingleDoses: NSData? = nil, singleTabletDoses: NSData? = nil, attribute1: NSData? = nil, attribute2: NSData? = nil, attribute3: NSData? = nil, classes: NSData? = nil, doses: NSData, doseUnit: String, drugID: String, effectiveness: String? = nil, endDate: Date? = nil, frequency: Double, ingredients: NSData? = nil, isCurrent: String, name: String, notes: String? = nil, regularly: Bool, reminders: NSData? = nil, sideEffects: NSData? = nil, startDate: Date, tablets: NSData? = nil, urid: String, effectDuration: Double) {
        self.dosagePlanDrug = dosagePlanDrug
        self.treatedSymptoms = treatedSymptoms
        self.maxDailyDoses = maxDailyDoses
        self.maxSingleDoses = maxSingleDoses
        self.singleTabletDoses = singleTabletDoses
        self.attribute1 = attribute1
        self.attribute2 = attribute2
        self.attribute3 = attribute3
        self.classes = classes
        self.doses = doses
        self.doseUnit = doseUnit
        self.drugID = drugID
        self.effectiveness = effectiveness
        self.endDate = endDate
        self.frequency = frequency
        self.ingredients = ingredients
        self.isCurrent = isCurrent
        self.name = name
        self.notes = notes
        self.regularly = regularly
        self.reminders = reminders
        self.sideEffects = sideEffects
        self.startDate = startDate
        self.tablets = tablets
        self.urid = urid
        self.uuid = UUID()
        self.effectDuration = effectDuration
    }
    
    
    @MainActor public func propertiesFromData(data: Data, container: ModelContainer) throws {
            
        var attributeDictionary: Dictionary<String,Data>?
        let attributeKeys = Mirror(reflecting: self).children.compactMap{ $0.label }
        
        attributeDictionary = try NSKeyedUnarchiver.unarchivedDictionary(keysOfClasses: [NSString.self], objectsOfClasses: [NSString.self, NSData.self, NSNumber.self, NSUUID.self], from: data) as? Dictionary<String,Data>
        
        
        for attributeData in attributeDictionary ?? [:] {
            
            
            if !attributeData.value.isEmpty {
                
                do {
                    
                    var value: Any?
                    
                    if attributeData.key == "attribute3" {
                        value = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(attributeData.value) as? Data
                    } else {
                        
                        value = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSArray.self ,NSNumber.self, NSString.self, NSData.self, NSDate.self, NSUUID.self], from: attributeData.value)
                    }
                    
                    if attributeKeys.contains(attributeData.key) {
                        switch attributeData.key {
                        case "startDate":
                            self.startDate = value as! Date
                        case "endDate":
                            self.endDate = value as? Date
                        case "dosagePlanDrug":
                            self.dosagePlanDrug = value as? String
                        case "treatedSymptoms":
                            self.treatedSymptoms = value as? NSData
                        case "maxDailyDoses":
                            self.maxDailyDoses = value as? NSData
                        case "maxSingleDoses":
                            self.maxSingleDoses = value as? NSData
                        case "singleTabletDoses":
                            self.singleTabletDoses = value as? NSData
                        case "attribute1":
                            self.attribute1 = value as? NSData
                        case "attribute2":
                            self.attribute2 = value as? NSData
                        case "attribute3":
                            self.attribute3 = value as? NSData
                        case "classes":
                            self.classes = value as? NSData
                        case "doses":
                            self.doses = value as! NSData
                        case "doseUnit":
                            self.doseUnit = value as! String
                        case "drugID":
                            self.drugID = value as! String
                        case "effectiveness":
                            self.effectiveness = value as? String
                        case "frequency":
                            self.frequency = value as! Double
                        case "ingredients":
                            self.ingredients = value as? NSData
                        case "isCurrent":
                            self.isCurrent = value as! String
                        case "name":
                            self.name = value as! String
                        case "notes":
                            self.notes = value as? String
                        case "regularly":
                            self.regularly = value as! Bool
                        case "reminders":
                            self.reminders = value as? NSData
                        case "sideEffects":
                            self.sideEffects = value as? NSData
                        case "tablets":
                            self.tablets = value as? NSData
                        case "urid":
                            self.urid = value as! String
                        case "uuid":
                            self.uuid = value as! UUID
                        case "effectDuration":
                            self.effectDuration = value as! Double
               default:
                            Logger().warning("unexpected or unused drug data key: \(attributeData.key)")
                        }
                    }
                } catch {
                    let ierror = InternalError(file: "Alogea_Drug", function: "propertiesFromData", appError: "error unarchiving attribute data : key: \(attributeData.key), value: \(attributeData.value)", osError: error.localizedDescription)
                    ErrorManager.addError(error: ierror, container: container)
                    continue
                }
            }
        }

    }

}
