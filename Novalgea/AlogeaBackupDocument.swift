//
//  AlogeaBackupDocument.swift
//  Novalgea
//
//  Created by aDev on 14/02/2024.
//

import UIKit

import UIKit
import SwiftUI
import SwiftData
import OSLog

protocol ImportDelegate {
    func progressUpdate(progress: Double)
}

class AlogeaBackupDocument: UIDocument {
    
    var eventsDictionaryData: Data?
    var drugsDictionaryData: Data?
    var recordTypesDictionaryData: Data?
    
    let logger = Logger()
    
    var events: [Alogea_Event]?
    var drugs: [Alogea_Drug]?
    var recordTypes: [Alogea_RecordType]?
    
    override func handleError(_ error: Error, userInteractionPermitted: Bool) {
        logger.error("Alogea backup file error: \(error.localizedDescription)")
    }
    
    override func contents(forType typeName: String) throws -> Any {
        
        var dataDictionaries: [String:Data]?
        
        guard eventsDictionaryData != nil else {
            throw InternalError(file: "AlogeaBackupDocument", function: "contents()", appError: "eventsDictionary is nil")
        }
        
        guard drugsDictionaryData != nil else {
            throw InternalError(file: "AlogeaBackupDocument", function: "contents()", appError: "drugsDictionary is nil")
        }
        
        guard recordTypesDictionaryData != nil else {
            throw InternalError(file: "AlogeaBackupDocument", function: "contents()", appError: "recordTypesDictionary is nil")
        }
        
        dataDictionaries = [String:Data]()
        dataDictionaries!["EventsDictionary"] = eventsDictionaryData
        dataDictionaries!["DrugsDictionary"] = drugsDictionaryData
        dataDictionaries!["RecordTypesDictionary"] = recordTypesDictionaryData
        
        return try archiveObject(object: dataDictionaries) as Any
    }
    
    func archiveObject(object: Any?) throws -> NSData? {
        
        var data = NSData()
        
        guard object != nil else {
            throw InternalError(file: "AlogeaBackupDocument", function: "archiveObject()", appError: "nil object passed for archiving")
        }
        
        data = try NSKeyedArchiver.archivedData(withRootObject: object!, requiringSecureCoding: false) as NSData
        
        return data
        
    }
    
    func unarchiveObject(data: Data?) throws -> Any? {
        
        guard data != nil else {
            throw InternalError(file: "AlogeaBackupDocument", function: "unarchiveObject()", appError: "nil object passed for un-archiving")
        }
        
        return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data!)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
        let dictionariesData = contents as? Data
        var dictionaries:[String:Data]?
        
        guard dictionariesData != nil else {
            throw InternalError(file: "AlogeaBackupDocument", function: "load()", appError: NSLocalizedString("Backup.loadError", comment: ""))
        }
        
        dictionaries = try unarchiveObject(data: dictionariesData) as? [String : Data]
        
        guard dictionaries != nil else {
            throw InternalError(file: "AlogeaBackupDocument", function: "load()", appError: NSLocalizedString("Backup.loadError", comment: ""))
        }
        
        eventsDictionaryData = dictionaries!["EventsDictionary"]
        drugsDictionaryData = dictionaries!["DrugsDictionary"]
        recordTypesDictionaryData = dictionaries!["RecordTypesDictionary"]
    }
    
    //MARK: - data extraction
    
    public func extractDataFromFile(container: ModelContainer) async {
        
        do {
            events = try extractEvents(container: container)
            drugs = try extractDrugs(container: container)
            recordTypes = try extractRecordTypes(container: container)
        } catch {
            let interror = InternalError(file: "AlogeaBackupDocument", function: "swiftDataFromAlogeaDiary", appError: "error extracting Alogea events from data", osError: error.localizedDescription)
            ErrorManager.addError(error: interror, container: container)
        }
    }
    
    public func extractEvents(container: ModelContainer) throws -> [Alogea_Event]? {
        
        guard let archivedEventsData = eventsDictionaryData else {
            return nil
        }
        var unarchivedData: Any?
        
        do {
            unarchivedData = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSArray.self, NSString.self, NSData.self], from: archivedEventsData)
        } catch {
            throw InternalError(file: "AlogeaBackupDocument", function: "extractEvents", appError: "failed to unarchive Alogea events data", osError: error.localizedDescription)
        }
        
        guard unarchivedData != nil else {
            return nil
        }
        
        guard let dataArray = unarchivedData as? [Data] else {
            throw InternalError(file: "AlogeaBackupDocument", function: "extractEvents", appError: "failed to convert Alogea events data to [Data] array")
        }
        
        var unarchivedEvents = [Alogea_Event]()
        
        for eventData in dataArray {
            let newEvent = Alogea_Event(date: .now, name: "A_Event", type: "default typw", urid: "default device")
            do {
                try newEvent.propertiesFromData(data: eventData, container: container)
                unarchivedEvents.append(newEvent)
            } catch {
                let interror = InternalError(file: "AlogeaBackupDocument", function: "extractEvents", appError: "error unarchiving an event", osError: error.localizedDescription)
                ErrorManager.addError(error: interror, container: container)
                continue
            }
        }
        
        return unarchivedEvents
        
    }
    
    public func extractDrugs(container: ModelContainer) throws -> [Alogea_Drug]? {
        
        guard let archivedEventsData = drugsDictionaryData else {
            return nil
        }
        var unarchivedData: Any?
        
        do {
            unarchivedData = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSArray.self, NSString.self, NSData.self], from: archivedEventsData)
        } catch {
            throw InternalError(file: "AlogeaBackupDocument", function: "extractDrugs", appError: "failed to unarchive Alogea drugs data", osError: error.localizedDescription)
        }
        
        guard unarchivedData != nil else {
            return nil
        }
        
        guard let dataArray = unarchivedData as? [Data] else {
            throw InternalError(file: "AlogeaBackupDocument", function: "extractDrugs", appError: "failed to convert Alogea drugs data to [Drug] array")
        }
        
        var unarchivedDrugs = [Alogea_Drug]()
        
        for drugData in dataArray {
            let newDrug = Alogea_Drug(doses: NSData(), doseUnit: "mg", drugID: "default drugID", frequency: 24*3600, isCurrent: "current", name: "default drug name", regularly: true, startDate: .now, urid: "device urid", effectDuration: 4*3600)
            do {
                try newDrug.propertiesFromData(data: drugData, container: container)
                unarchivedDrugs.append(newDrug)
            } catch {
                let interror = InternalError(file: "AlogeaBackupDocument", function: "extractEvents", appError: "error unarchiving an event", osError: error.localizedDescription)
                ErrorManager.addError(error: interror, container: container)
                continue
            }
        }
        
        return unarchivedDrugs
        
    }
    
    public func extractRecordTypes(container: ModelContainer) throws -> [Alogea_RecordType]? {
        
        guard let archivedEventsData = recordTypesDictionaryData else {
            return nil
        }
        var unarchivedData: Any?
        
        do {
            unarchivedData = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSArray.self, NSString.self, NSData.self], from: archivedEventsData)
        } catch {
            throw InternalError(file: "AlogeaBackupDocument", function: "extractEvents", appError: "failed to unarchive Alogea events data", osError: error.localizedDescription)
        }
        
        guard unarchivedData != nil else {
            return nil
        }
        
        guard let dataArray = unarchivedData as? [Data] else {
            throw InternalError(file: "AlogeaBackupDocument", function: "extractEvents", appError: "failed to convert Alogea recordType data to [Data] array")
        }
        
        var unarchivedRecordTypes = [Alogea_RecordType]()
        
        for recordTypeData in dataArray {
            let newRecordType = Alogea_RecordType(dateCreated: .now, name: "default symptoms", minScore: 0, maxScore: 10, urid: "default urid")
            do {
                try newRecordType.propertiesFromData(data: recordTypeData, container: container)
                unarchivedRecordTypes.append(newRecordType)
            } catch {
                let interror = InternalError(file: "AlogeaBackupDocument", function: "extractEvents", appError: "error unarchiving a recordType (symptom)", osError: error.localizedDescription)
                ErrorManager.addError(error: interror, container: container)
                continue
            }
        }
        
        return unarchivedRecordTypes
        
    }
    
    //MARK: - import extracted data
    
    public func importAlogeaRecords(replaceCurrentRecords: Bool, container: ModelContainer, delegate: ImportDelegate) async throws {
        
        let context = container.mainContext // do NOT use ModelContext(container)! object inserted into this ontext won't be persisted
        
        if replaceCurrentRecords {
            try context.delete(model: DiaryEvent.self)
            try context.delete(model: ExerciseEvent.self)
            try context.delete(model: Medicine.self)
            try context.delete(model: PRNMedEvent.self)
            try context.delete(model: Rating.self)
            try context.delete(model: Symptom.self)
        }
        
        DispatchQueue.main.async {
            delegate.progressUpdate(progress: 0.2)
        }

        let fetchDescriptorS = FetchDescriptor<Symptom>(sortBy: [SortDescriptor(\Symptom.name)])
        var existingSymptoms = try? context.fetch(fetchDescriptorS)
        
        for symptom in recordTypes ?? [] {
            if existingSymptoms?.count ?? 0 < 1 {
                let newSymptom = Symptom(name: symptom.name, type: UserText.term(english: "Symptom"), creatingDevice: symptom.urid.components(separatedBy: " ").first ?? UIDevice.current.name)
                context.insert(newSymptom)
                existingSymptoms?.append(newSymptom)
                
            } else if !(existingSymptoms!.compactMap { $0.name }.contains(symptom.name)) {
                let newSymptom = Symptom(name: symptom.name, type: UserText.term(english: "Symptom"), creatingDevice: symptom.urid.components(separatedBy: " ").first ?? UIDevice.current.name)
                context.insert(newSymptom)
                existingSymptoms?.append(newSymptom)
            }
        }
        
        DispatchQueue.main.async {
            delegate.progressUpdate(progress: 0.3)
        }

        
        for drug in drugs ?? [] {
            let newMedicine = Medicine(name: "Sample medicine",doses: [Dose(unit: "mg", value1: 1000)])
            context.insert(newMedicine)
            
            newMedicine.name = drug.name
            newMedicine.startDate = drug.startDate
            newMedicine.endDate = drug.endDate
            newMedicine.effectDuration = drug.frequency
            newMedicine.creatingDevice = drug.urid
            let currentComponents = drug.isCurrent.components(separatedBy: " ")
            newMedicine.currentStatus = currentComponents.first ?? "Current"
            newMedicine.isRegular = drug.regularly
            newMedicine.notes = drug.notes
            newMedicine.effect = drug.effectiveness
            
            if let doses = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: NSNumber.self, from: drug.doses as Data) as? [[Double]] {
                
                var reminders = [true]
                
                if let archivedReminderData = drug.reminders as? Data {
                    if let archivedReminders = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: NSNumber.self, from: archivedReminderData) as? [Bool] {
                        reminders = archivedReminders
                    }
                }
                
                let unit = drug.doseUnit
                var newDoses = [Dose]()
                var time = drug.startDate
                var doseCount = 0
                for aDose in doses {
                    var doseReminder = true
                    if reminders.count >= doseCount {
                        doseReminder = reminders[doseCount]
                    }
                    var newDose = Dose(time: time, reminderIsOn: doseReminder ,unit: unit, value1: aDose.first ?? 0)
                    if aDose.count > 1 {
                        newDose.value2 = aDose.last ?? 0
                    }
                    newDoses.append(newDose)
                    time = time.addingTimeInterval(newMedicine.effectDuration)
                    doseCount += 1
                }
                newMedicine.doses = newDoses.convertToData()
            }
            
            if let classData = drug.classes as? Data {
                if let classes = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: NSString.self, from: classData) as? [String] {
                    newMedicine.drugClass = classes.combinedString()
                }
            }
            
            if let symptomData = drug.treatedSymptoms as? Data {
                if let unarchivedSymptoms = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: NSString.self, from: symptomData) as? [String] {
                    
                    var treatedSymptoms = [Symptom]()
                    
                    if existingSymptoms?.count ?? 0 > 0 {
                        //existing symptoms - check, don't duplicate
                        for symptom in unarchivedSymptoms {
                            if existingSymptoms!.compactMap({ $0.name }).contains(symptom) {
                                
                                treatedSymptoms.append(existingSymptoms!.filter({ asymptom in
                                    if asymptom.name == symptom{ return true }
                                    else { return false }
                                }).first!)
                                
                            }
                            else  {
                                // no existing symptom - create new
                                let newSymptom = Symptom(name: "Sample symptom", type: UserText.term(english: "Symptom"), creatingDevice: UIDevice.current.name)
                                treatedSymptoms.append(newSymptom)
                                existingSymptoms?.append(newSymptom)
                            }
                        }
                    }
                    else {
                        // no existing symptoms - create new
                        for symptom in unarchivedSymptoms {
                            let newSymptom = Symptom(name: symptom, type: UserText.term(english: "Symptom"), creatingDevice: UIDevice.current.name)
                            treatedSymptoms.append(newSymptom)
                            existingSymptoms?.append(newSymptom)
                        }
                    }
                    
                    newMedicine.treatedSymptoms = treatedSymptoms
                }
                
            }
            
            if let ratingRemindersData = drug.attribute1 as? Data {
                if let archivedRatingReminderOn = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSNumber.self, from: ratingRemindersData) as? Bool {
                    newMedicine.ratingRemindersOn = archivedRatingReminderOn
                }
            }
            
            if let recommendedDurationData = drug.attribute2 as? Data {
                if let recommendedDuration = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSNumber.self, from: recommendedDurationData) as? Double {
                    newMedicine.recommendedDuration = recommendedDuration
                }
            }
            
            if let maxSingleDosesData = drug.maxSingleDoses as? Data {
                if let maxSingleDoses = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: NSNumber.self, from: maxSingleDosesData) as? [Double] {
                    newMedicine.maxSingleDose = maxSingleDoses.max()
                }
            }
            
            if let maxDailyDosesData = drug.maxDailyDoses as? Data {
                if let maxDailyDoses = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: NSNumber.self, from: maxDailyDosesData) as? [Double] {
                    newMedicine.maxDailyDose = maxDailyDoses.max()
                }
            }
            
            // TODO: - the effect/success of this needs to be checked
            if let sideEffectsData = drug.sideEffects as? Data {
                
                if let unarchivedSideEffects = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: NSString.self, from: sideEffectsData) as? [String] {
                    
                    var sideEffects = [Symptom]()
                    for sideEffect in unarchivedSideEffects {
                        // no existing symptom - create new
                        let newSE = Symptom(name: UserText.term(english: "Unspecified side effect"), type: UserText.term(english: "Side effect"), creatingDevice: UIDevice.current.name, causingMeds: [newMedicine])
                        // the side effect is 'reversely' added the the new Medicine by including it in the RelationShip causingMeds in this SideEffect-Symptom; this should create a reverse RelationShip in new medicine adding the SideEffect-Symptom
                        var vas: Double
                        switch sideEffect {
                        case UserText.term(english: "Meds.sideEffect.none"):
                            vas = 0.0
                        case UserText.term(english: "Meds.sideEffect.minimal"):
                            vas = 1.5
                        case UserText.term(english: "Meds.sideEffect.moderate"):
                            vas = 5.0
                        case UserText.term(english: "Meds.sideEffect.strong"):
                            vas = 8.0
                        default:
                            vas = 0.0
                       }
                        let newRating = Rating(vas: vas, ratedSymptom: newSE,date: drug.startDate.addingTimeInterval(3*24*3600))
                        context.insert(newRating)
                        sideEffects.append(newSE)
                    }
                }
            }
            
            if let reviewDatesData = drug.attribute3 as? Data {
                if let dates = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: NSDate.self, from: reviewDatesData) as? [Date] {
                    let proposedReviewDate = dates.first
                    let proposedStopDate = dates.count > 1 ? dates[1] : nil
                    let nextMildSevereReviewDate = dates.count > 2 ? dates[2] : nil
                    let nextOverdoseCheckDate = dates.count > 3 ? dates[3] : nil
                    let nextEffectCheckDate = dates.count > 4 ? dates[4] : nil
                    newMedicine.reviewDates = ReviewDates(proposedReviewDate: proposedReviewDate, proposedStopDate: proposedStopDate, nextMildSevereReviewDate: nextMildSevereReviewDate, nextOverdoseCheckDate: nextOverdoseCheckDate, nextEffectCheckDate: nextEffectCheckDate).convertToData()
                }
            }
        }

        DispatchQueue.main.async {
            delegate.progressUpdate(progress: 0.6)
        }
                
        let fetchDescriptorM = FetchDescriptor<Medicine>(sortBy: [SortDescriptor(\Medicine.name)])
        let existingMedicines = try? context.fetch(fetchDescriptorM)
        

        for event in events ?? [] {
            
            switch event.type {
            case "Score Event":
                var ratedSymptom: Symptom
                if (existingSymptoms ?? []).compactMap({ $0.name }).contains(event.name) {
                    ratedSymptom = existingSymptoms!.filter({ exSymptom in
                        if exSymptom.name == event.name { return true }
                        else { return false }
                    }).first!
                }
                else {
                    let newSymptom = Symptom(name: event.name, type: UserText.term(english: "Symptom"), creatingDevice: event.urid.components(separatedBy: " ").first ?? UIDevice.current.name)
                    context.insert(newSymptom)
                    context.insert(newSymptom)
                    existingSymptoms?.append(newSymptom)
                    ratedSymptom = newSymptom
                }
                let newRating = Rating(vas: event.vas?.doubleValue ?? 0, ratedSymptom: ratedSymptom, date: event.date)
                context.insert(newRating)
            case "Diary Entry":
                let newDiaryEvent = DiaryEvent(date: event.date, category: event.name, notes: event.note ?? "")
                context.insert(newDiaryEvent)
                if let duration = event.duration?.doubleValue {
                    newDiaryEvent.endDate = newDiaryEvent.date.addingTimeInterval(duration)
                }
            case "Medicine Event":
                let matchingMedicines = (existingMedicines ?? []).filter { medicine in
                    if medicine.name == event.name { return true }
                    else { return false }
                }
                guard let match = matchingMedicines.first else {
                    continue
                }
                let endDate = event.date.addingTimeInterval(match.effectDuration)
                let newMedEvent = PRNMedEvent(endDate: endDate, startDate: event.date, medicine: match)
                context.insert(newMedEvent)
            case "Exercise Event":
                let newExEvent = ExerciseEvent(exercise: event.name, date: event.date, unit: event.note ?? "-", value: event.vas?.doubleValue ?? 0)
                context.insert(newExEvent)
                if let duration = event.duration?.doubleValue {
                    newExEvent.endDate = newExEvent.startDate.addingTimeInterval(duration)
                }
            default:
                let ierror = InternalError(file: "Alogea Backup Document", function: "importAlogeaRecords()", appError: "unexpcted imported event type: \(event.type)")
                context.insert(ierror)
            }
        }
        
    }
    
}


