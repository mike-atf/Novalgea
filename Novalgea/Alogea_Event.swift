//
//  Alogea_Event.swift
//  Novalgea
//
//  Created by aDev on 15/02/2024.
//

import SwiftData
import SwiftUI
import OSLog

class Alogea_Event: NSObject {
    
     var date: Date
     var duration: NSNumber? // for medEvents contains effect duration, for exerciseEvent contains time of exercise (for both timed and step- or distance-measured events!
     var bodyLocation: String? // currently unused (1.4)
     var name: String // rating category for ratingEvents, drug name for medicineEvents and exercise ('Walking' etc) for exerciseEvents
     var note: String? // for exercise Events contains min,meters or steps/repeats; empty is interpreted as min (time), although the number contained in durtaiton is actually seconds, nit minutes
     var outcome: String? // stores drugID in case is medicineEvent
     var type: String // ratingEvent, non-scoreEvent, medicationEvent or exerciseEvent
     var vas: NSNumber? // vas ratingEvents contains the rating, for exerciseEvents the cont of steps or meters for non-timed exerciseEvents; (notes contains meters or steps/repeats)
     var urid: String // at awakeFromInsert; string with device name and string from date of creation
     var symptomImpact: Data? // contains dictionary [String:Bool?] for [symptom:y/n?]
     var eventID: UUID?
    
    init(date: Date, duration: NSNumber? = nil, name: String, note: String? = nil, outcome: String? = nil, type: String, vas: NSNumber? = nil, urid: String, symptomImpact: Data? = nil) {
        self.date = date
        self.duration = duration
        self.bodyLocation = nil
        self.name = name
        self.note = note
        self.outcome = outcome
        self.type = type
        self.vas = vas
        self.urid = urid
        self.symptomImpact = symptomImpact
        self.eventID = UUID()
    }
    
    @MainActor public func propertiesFromData(data: Data, container: ModelContainer) throws {
            
        var attributeDictionary: Dictionary<String,Data>?
        
        attributeDictionary = try NSKeyedUnarchiver.unarchivedDictionary(keysOfClasses: [NSString.self], objectsOfClasses: [NSData.self, NSDate.self, NSString.self, NSNumber.self], from: data) as? Dictionary<String,Data>
        
        let attributeKeys = Mirror(reflecting: self).children.compactMap{ $0.label }
        
        for attributeData in attributeDictionary ?? [:] {
            if !attributeData.value.isEmpty {
                
                
                do {
                    let value = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSArray.self ,NSNumber.self, NSString.self, NSData.self, NSDate.self, NSUUID.self], from: attributeData.value)
                    
                    if attributeKeys.contains(attributeData.key) {
                        switch attributeData.key {
                        case "date":
                            self.date = value as! Date
                        case "duration":
                            self.duration = value as? NSNumber
                        case "name":
                            self.name = value as! String
                        case "note":
                            self.note = value as? String
                        case "outcome":
                            self.outcome = value as? String
                        case "type":
                            self.type = value as! String
                        case "vas":
                            self.vas = value as? NSNumber
                        case "urid":
                            self.urid = value as! String
                        case "symptomImpact":
                            self.symptomImpact = value as? Data
                        case "eventID":
                            self.eventID = value as? UUID
                        default:
                            Logger().warning("unexpected or unsused event data key: \(attributeData.key)")
                        }
                    }
                } catch {
                    let ierror = InternalError(file: "Alogea_Events", function: "propertiesFromData", appError: "error unarchiving attribute data : key: \(attributeData.key), value: \(attributeData.value)", osError: error.localizedDescription)
                    ErrorManager.addError(error: ierror, container: container)
                    continue
                }
            }
        }

    }

}
