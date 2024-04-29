//
//  AlogeaBackupDocument.swift
//  Novalgea
//
//  Created by aDev on 14/02/2024.
//
#if canImport(UIKit)
import UIKit
#endif
import SwiftUI
import SwiftData
import OSLog


@Observable class AlogeaBackupDocument: UIDocument {
    
    var fileName = "AlogeaBackupDocument"
    var eventsDictionaryData: Data?
    var drugsDictionaryData: Data?
    var recordTypesDictionaryData: Data?
    
    let logger = Logger()
    
    var events = [Alogea_Event]()
    var drugs = [Alogea_Drug]()
    var recordTypes = [Alogea_RecordType]()
    
    var completedImportTasks: Double = 0
    var totalImportTasks: Double = 1
    
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
    
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        
        let dictionariesData = contents as? Data
        var dictionaries:[String:Data]?
        
        guard dictionariesData != nil else {
            throw InternalError(file: "AlogeaBackupDocument", function: "load()", appError: NSLocalizedString("Backup.loadError", comment: ""))
        }
        
        dictionaries = try? NSKeyedUnarchiver.unarchivedDictionary(ofKeyClass: NSString.self, objectClass: NSData.self, from: dictionariesData!) as? [String : Data]
        
        guard dictionaries != nil else {
            throw InternalError(file: "AlogeaBackupDocument", function: "load()", appError: NSLocalizedString("Backup.loadError", comment: ""))
        }
        
        eventsDictionaryData = dictionaries!["EventsDictionary"]
        drugsDictionaryData = dictionaries!["DrugsDictionary"]
        recordTypesDictionaryData = dictionaries!["RecordTypesDictionary"]
    }
    
    //MARK: - data extraction
    
    /// returns in date desecending order
    public func extractDataFromFile(container: ModelContainer) async {
        
        do {
            // arrays are returned in date descending order
            events = try extractEvents(container: container) ?? [Alogea_Event]()
            drugs = try extractDrugs(container: container) ?? [Alogea_Drug]()
            recordTypes = try extractRecordTypes(container: container) ?? [Alogea_RecordType]()
        } catch {
            let interror = InternalError(file: "AlogeaBackupDocument", function: "swiftDataFromAlogeaDiary", appError: "error extracting Alogea events from data", osError: error.localizedDescription)
            ErrorManager.addError(error: interror, container: container)
        }
    }
    
    /// returns in date desecending order
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
        
        return unarchivedEvents.sorted { e1, e2 in
            if e2.date < e1.date { return true }
            else { return false }
        }
        
    }
    
    
    /// returns in date descending oder
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
        
        return unarchivedDrugs.sorted { e1, e2 in
            if e2.startDate < e1.startDate { return true }
            else { return false }
        }
        
    }
    
    /// returns in date descending oder
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
        
        return unarchivedRecordTypes.sorted { e1, e2 in
            if e2.dateCreated < e1.dateCreated { return true }
            else { return false }
        }
        
    }
    
    //MARK: - import extracted data
    
    public func importAlogeaRecords(container: ModelContainer) async throws {
        
        let context = container.mainContext // do NOT use ModelContext(container)! object inserted into this context won't be persisted

        let fetchDescriptorS = FetchDescriptor<Symptom>(sortBy: [SortDescriptor(\Symptom.name)])
        var existingSymptoms = try? context.fetch(fetchDescriptorS)
        var index = 0
        for symptom in recordTypes {
            let colorSchemeIndex = index%ColorScheme.symptomColorsArray.count
            if existingSymptoms?.count ?? 0 < 1 {
                let newSymptom = Symptom(name: symptom.name, type: UserText.term("Symptom"), creatingDevice: symptom.urid.components(separatedBy: " ").first ?? UIDevice.current.name, colorName: "s\(colorSchemeIndex)")
                context.insert(newSymptom)
                existingSymptoms?.append(newSymptom)
                
            } else if !(existingSymptoms!.compactMap { $0.name }.contains(symptom.name)) {
                let newSymptom = Symptom(name: symptom.name, type: UserText.term("Symptom"), creatingDevice: symptom.urid.components(separatedBy: " ").first ?? UIDevice.current.name, colorName: "s\(colorSchemeIndex)")
                context.insert(newSymptom)
                existingSymptoms?.append(newSymptom)
            }
            index += 1
        }
        
        index = 0
        for drug in drugs {
            let colorSchemeIndex = index%ColorScheme.medicineColorsArray.count
            let newMedicine = Medicine(name: "Sample medicine",doses: [Dose(unit: "mg", value1: 1000)], colorName: "m\(colorSchemeIndex)")
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
            
            if let effect = drug.effectiveness {
                var vas: Double = 0
                
                switch effect {
                    // TODO: - test this for correct function in translations
                case UserText.term("General.none"):
                    vas = 0
                case UserText.term("General.minimal"):
                    vas = 2.0
                case UserText.term("General.moderate"):
                    vas = 4.0
                case UserText.term("General.good"):
                    vas = 7.0
                default:
                    let ierror = InternalError(file: "Alogea backup Document", function: "importAlogeaRecords", appError: "unrecognised Alogea Medicine effect term encountered and ignored")
                    ErrorManager.addError(error: ierror, container: container)
                }
                
                let treatmentDuration = (newMedicine.endDate ?? .now).timeIntervalSince(newMedicine.startDate)
                let ratingDate1 = newMedicine.startDate.addingTimeInterval(treatmentDuration / 2)
                let ratingDate2 = newMedicine.endDate ?? .now.addingTimeInterval(-24*3600)
                let effectRating1 = Rating(vas: vas, ratedSymptom: nil, date: ratingDate1, ratedMedicine: newMedicine)
                let effectRating2 = Rating(vas: vas, ratedSymptom: nil, date: ratingDate2 ,ratedMedicine: newMedicine)
                context.insert(effectRating1)
                context.insert(effectRating2)
            }
            
            if let doses = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [NSNumber.self, NSData.self], from: drug.doses as Data) as? [[Double]] {
                
                var reminders = [true]
                
                if let archivedReminderData = drug.reminders as? Data {
                    if let archivedReminders = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [NSNumber.self, NSData.self], from: archivedReminderData) as? [Bool] {
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
                if let classes = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [NSString.self, NSData.self], from: classData) as? [String] {
                    newMedicine.drugClass = classes.combinedString()
                }
            }
            
            if let symptomData = drug.treatedSymptoms as? Data {
                if let unarchivedSymptoms = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [NSString.self, NSData.self], from: symptomData) as? [String] {
                    
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
                                let randomIndex = Int.random(in: 0..<ColorScheme.symptomColorsArray.count)
                                let colorName = "s\(randomIndex)"
                                let newSymptom = Symptom(name: "Sample symptom", type: UserText.term("Symptom"), creatingDevice: UIDevice.current.name, colorName: colorName)
                                treatedSymptoms.append(newSymptom)
                                existingSymptoms?.append(newSymptom)
                            }
                        }
                    }
                    else {
                        // no existing symptoms - create new
                        for symptom in unarchivedSymptoms {
                            let newSymptom = Symptom(name: symptom, type: UserText.term("Symptom"), creatingDevice: UIDevice.current.name)
                            treatedSymptoms.append(newSymptom)
                            existingSymptoms?.append(newSymptom)
                        }
                    }
                    
                    newMedicine.treatedSymptoms = treatedSymptoms
                }
                
            }
            
            if let ratingRemindersData = drug.attribute1 as? Data {
                if let archivedRatingReminderOn = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSNumber.self, NSData.self], from: ratingRemindersData) as? Bool {
                    newMedicine.ratingRemindersOn = archivedRatingReminderOn
                }
            }
            
            if let recommendedDurationData = drug.attribute2 as? Data {
                if let recommendedDuration = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSNumber.self, NSData.self], from: recommendedDurationData) as? Double {
                    newMedicine.recommendedDuration = recommendedDuration
                }
            }
            
            if let maxSingleDosesData = drug.maxSingleDoses as? Data {
                if let maxSingleDoses = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [NSNumber.self, NSData.self], from: maxSingleDosesData) as? [Double] {
                    newMedicine.maxSingleDose = maxSingleDoses.max()
                }
            }
            
            if let maxDailyDosesData = drug.maxDailyDoses as? Data {
                if let maxDailyDoses = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [NSNumber.self, NSData.self], from: maxDailyDosesData) as? [Double] {
                    newMedicine.maxDailyDose = maxDailyDoses.max()
                }
            }
            
            // TODO: - the effect/success of this needs to be checked
            if let sideEffectsData = drug.sideEffects as? Data {
                
                if let unarchivedSideEffects = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [NSString.self,NSData.self], from: sideEffectsData) as? [String] { // expected to contain only one element
                    
                    var sideEffects = [Symptom]()
                    for sideEffect in unarchivedSideEffects {
                        // no existing symptom - create new
                        let seColorIndex = Int.random(in: 0..<ColorScheme.symptomColorsArray.count)
                        let newSE = Symptom(name: drug.name + UserText.term(" side effect"), type: UserText.term("Side effect"), creatingDevice: UIDevice.current.name, causingMeds: [newMedicine], colorName: "s\(seColorIndex)")
                        // the side effect is 'reversely' added the the new Medicine by including it in the RelationShip causingMeds in this SideEffect-Symptom; this should create a reverse RelationShip in new medicine adding the SideEffect-Symptom
                        var vas: Double
                        switch sideEffect {
                        case UserText.term("Meds.sideEffect.none"):
                            vas = 0.0
                        case UserText.term("Meds.sideEffect.minimal"):
                            vas = 1.5
                        case UserText.term("Meds.sideEffect.moderate"):
                            vas = 5.0
                        case UserText.term("Meds.sideEffect.strong"):
                            vas = 8.0
                        default:
                            vas = 0.0
                       }
                        let newRating1 = Rating(vas: vas, ratedSymptom: newSE,date: drug.startDate.addingTimeInterval(3*24*3600))
                        let newRating2 = Rating(vas: vas, ratedSymptom: newSE,date: (drug.endDate ?? .now))
                        context.insert(newRating1)
                        context.insert(newRating2)
                        sideEffects.append(newSE)
                    }
                }
            }
            
            if let reviewDatesData = drug.attribute3 as? Data {
                if let dates = try? NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [NSDate.self, NSData.self], from: reviewDatesData) as? [Date] {
                    let proposedReviewDate = dates.first
                    let proposedStopDate = dates.count > 1 ? dates[1] : nil
                    let nextMildSevereReviewDate = dates.count > 2 ? dates[2] : nil
                    let nextOverdoseCheckDate = dates.count > 3 ? dates[3] : nil
                    let nextEffectCheckDate = dates.count > 4 ? dates[4] : nil
                    newMedicine.reviewDates = ReviewDates(proposedReviewDate: proposedReviewDate, proposedStopDate: proposedStopDate, nextMildSevereReviewDate: nextMildSevereReviewDate, nextOverdoseCheckDate: nextOverdoseCheckDate, nextEffectCheckDate: nextEffectCheckDate).convertToData()
                }
            }
            
            if drug.regularly {
                let regularMedEvent = MedicineEvent(endDate: drug.endDate, startDate: drug.startDate ,medicine: newMedicine)
                context.insert(regularMedEvent)
            }
            
            completedImportTasks += 1.0
        }

        let fetchDescriptorM = FetchDescriptor<Medicine>(sortBy: [SortDescriptor(\Medicine.name)])
        let existingMedicines = try? context.fetch(fetchDescriptorM)
        
        var uniqueRatingDates = [String]() // TODO: - remove; to account for own faulty diary data with lots of duplicate ratings from May 19 and earlier
        let checkDate = Date().setDate(day: 31, month: 05, year: 2019)!
        
        let diaryEvents = events.filter { event in
            if event.type == "Diary Entry" { return true } // this is the term used in Alogea for all languages
            else { return false }
        }
        
        let categoryNames = Set(diaryEvents.compactMap { $0.name })
        var importedCategories = [EventCategory]()
        for name in categoryNames {
            let symbol = SymbolScheme.eventCategorySymbols.randomElement()!
            let new = EventCategory(name: name, symbol: symbol, colorName: ColorScheme.categoryColors.keys.randomElement())
            importedCategories.append(new)
            context.insert(new)
        }
        let unkown = EventCategory(name: UserText.term("Unknown category"), color: Color.primary)

        for event in events {
            
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
                    let newSymptom = Symptom(name: event.name, type: UserText.term("Symptom"), creatingDevice: event.urid.components(separatedBy: " ").first ?? UIDevice.current.name, colorName: ColorScheme.symptomColors.keys.randomElement())
                    context.insert(newSymptom)
                    context.insert(newSymptom)
                    existingSymptoms?.append(newSymptom)
                    ratedSymptom = newSymptom
                }
                let newRating = Rating(vas: event.vas?.doubleValue ?? 0, ratedSymptom: ratedSymptom, date: event.date)
                //TODO: - remove
                if event.date < checkDate {
                    Logger().info("\(event.date.formatted(.dateTime.day().month().year().hour().minute().second()))")
                }
                if !uniqueRatingDates.contains(newRating.date.formatted(.dateTime.day().month().year().hour().minute().second())) {
                    uniqueRatingDates.append(newRating.date.formatted(.dateTime.day().month().year().hour().minute().second()))
                    context.insert(newRating) // <- KEEP THIS
                }
                
            case "Diary Entry":
                var matchingCategory = importedCategories.category(named: event.name)
                if matchingCategory == nil {
                    context.insert(unkown)
                    matchingCategory = unkown
                }
                let newDiaryEvent = DiaryEvent(date: event.date, category: matchingCategory!, notes: event.note ?? "")
                if let duration = event.duration?.doubleValue {
                    newDiaryEvent.endDate = newDiaryEvent.date.addingTimeInterval(duration)
                }
                context.insert(newDiaryEvent)
            case "Medicine Event":
                let matchingMedicines = (existingMedicines ?? []).filter { medicine in
                    if medicine.name == event.name { return true }
                    else { return false }
                }
                guard let match = matchingMedicines.first else {
                    continue
                }
                let endDate = event.date.addingTimeInterval(match.effectDuration)
                let newMedEvent = MedicineEvent(endDate: endDate, startDate: event.date, medicine: match)
                context.insert(newMedEvent)
            case "Exercise Event":
                let newExEvent = ExerciseEvent(exercise: event.name, date: event.date, unit: event.note ?? "-", value: event.vas?.doubleValue ?? 0)
                if let duration = event.duration?.doubleValue {
                    newExEvent.endDate = newExEvent.startDate.addingTimeInterval(duration)
                }
                context.insert(newExEvent)
            default:
                let ierror = InternalError(file: "Alogea Backup Document", function: "importAlogeaRecords()", appError: "unexpcted imported event type: \(event.type)")
                context.insert(ierror)
            }
            
        }
        
    }
    
}

//class ImportDelegate: ObservableObject {
//    
//    @Published var completedTasks: Double = 0
//    @Published var totalTasks: Double = 1
//    
//}


