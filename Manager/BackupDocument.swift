//
//  BackupDocument.swift
//  Novalgea
//
//  Created by aDev on 22/02/2024.
//

import Foundation
import UIKit

class BackupDocument: UIDocument {
    
    var diaryEventDictionaryData: Data?
    var medicinesDictionaryData: Data?
    var symptomsDictionaryData: Data?
    var ratingsDictionaryData: Data?
    var exerciseEventDictionaryData: Data?
    var prnMedEventsDictionaryData: Data?
    
    enum DataDictionaryType: String {
        case diaryEvents = "diaryEvents"
        case medicines = "medicines"
        case symptoms = "symptoms"
        case ratings = "ratings"
        case prnMedEvents = "prnMedEvents"
        case exerciseEvents = "exerciseEvents"
    }

    override func contents(forType typeName: String) throws -> Any {
        
        guard diaryEventDictionaryData != nil else {
            throw InternalError(file: "BackupDocument", function: "contents()", appError: "diaryEvents Dictionary Data is nil")
        }        
        guard medicinesDictionaryData != nil else {
            throw InternalError(file: "BackupDocument", function: "contents()", appError: "medicines Dictionary Data is nil")
        }
        guard symptomsDictionaryData != nil else {
            throw InternalError(file: "BackupDocument", function: "contents()", appError: "symptoms Dictionary Data is nil")
        }
        guard ratingsDictionaryData != nil else {
            throw InternalError(file: "BackupDocument", function: "contents()", appError: "ratings Dictionary Data is nil")
        }
        guard prnMedEventsDictionaryData != nil else {
            throw InternalError(file: "BackupDocument", function: "contents()", appError: "prn med events Dictionary Data is nil")
        }
        guard exerciseEventDictionaryData != nil else {
            throw InternalError(file: "BackupDocument", function: "contents()", appError: "exercise events Dictionary Data is nil")
        }


        var dataDictionaries = [String:Data]()
        dataDictionaries[DataDictionaryType.diaryEvents.rawValue] = diaryEventDictionaryData
        dataDictionaries[DataDictionaryType.medicines.rawValue] = medicinesDictionaryData
        dataDictionaries[DataDictionaryType.symptoms.rawValue] = symptomsDictionaryData
        dataDictionaries[DataDictionaryType.ratings.rawValue] = ratingsDictionaryData
        dataDictionaries[DataDictionaryType.prnMedEvents.rawValue] = prnMedEventsDictionaryData
        dataDictionaries[DataDictionaryType.exerciseEvents.rawValue] = exerciseEventDictionaryData

        return try NSKeyedArchiver.archivedData(withRootObject: dataDictionaries, requiringSecureCoding: true) as NSData
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
        guard let dictionariesData = contents as? Data else {
            throw InternalError(file: "Backup Document", function: "load()", appError: "backup file contents are not in the required data format")
        }
        
        guard var dictionaries = try NSKeyedUnarchiver.unarchivedDictionary(keysOfClasses: [NSString.self], objectsOfClasses: [NSData.self], from: dictionariesData) as? [String : Data] else {
            throw InternalError(file: "Backup Document", function: "load()", appError: "backup file contents couldn't be converted to data dictionaries")

        }

        diaryEventDictionaryData = dictionaries[DataDictionaryType.diaryEvents.rawValue]
        medicinesDictionaryData = dictionaries[DataDictionaryType.medicines.rawValue]
        symptomsDictionaryData = dictionaries[DataDictionaryType.symptoms.rawValue]
        ratingsDictionaryData = dictionaries[DataDictionaryType.ratings.rawValue]
        prnMedEventsDictionaryData = dictionaries[DataDictionaryType.prnMedEvents.rawValue]
        exerciseEventDictionaryData = dictionaries[DataDictionaryType.exerciseEvents.rawValue]

    }

}
