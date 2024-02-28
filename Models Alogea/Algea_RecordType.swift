//
//  Algea_RecordType.swift
//  Novalgea
//
//  Created by aDev on 15/02/2024.
//

import Foundation
import SwiftData
import OSLog

class Alogea_RecordType {
    
     var dateCreated: Date
     var name: String
     var minScore: NSNumber
     var maxScore: NSNumber
     var urid: String
    
    init(dateCreated: Date, name: String, minScore: NSNumber, maxScore: NSNumber, urid: String) {
        self.dateCreated = dateCreated
        self.name = name
        self.minScore = minScore
        self.maxScore = maxScore
        self.urid = urid
    }
    
    @MainActor public func propertiesFromData(data: Data, container: ModelContainer) throws {
            
        var attributeDictionary: Dictionary<String,Data>?
        
        attributeDictionary = try NSKeyedUnarchiver.unarchivedDictionary(keysOfClasses: [NSString.self], objectsOfClasses: [NSDate.self, NSString.self, NSNumber.self], from: data) as? Dictionary<String,Data>
        
        let attributeKeys = Mirror(reflecting: self).children.compactMap{ $0.label }
        
        for attributeData in attributeDictionary ?? [:] {
            if !attributeData.value.isEmpty {
                
                
                do {
                    let value = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSNumber.self, NSString.self, NSDate.self, NSData.self], from: attributeData.value)
                    
                    if attributeKeys.contains(attributeData.key) {
                        switch attributeData.key {
                        case "dateCreated":
                            self.dateCreated = value as! Date
                        case "name":
                            self.name = value as! String
                        case "minScore":
                            self.minScore = value as! NSNumber
                        case "maxScore":
                            self.maxScore = value as! NSNumber
                        case "urid":
                            self.urid = value as! String
                        default:
                            Logger().warning("unexpected or unsused RecordType (Symptom) data key: \(attributeData.key)")
                        }
                    }
                } catch {
                    let ierror = InternalError(file: "Alogea_RecordType", function: "propertiesFromData", appError: "error unarchiving attribute data : key: \(attributeData.key), value: \(attributeData.value)", osError: error.localizedDescription)
                    ErrorManager.addError(error: ierror, container: container)
                    continue
                }
            }
        }

    }


}
