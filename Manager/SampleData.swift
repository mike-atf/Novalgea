//
//  SampleData.swift
//  Novalgea
//
//  Created by aDev on 27/03/2024.
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftData

@MainActor class SampleData {
    
     class func createSampleData(checkIfExist: Bool, _in container: ModelContainer) {
        
        let context = container.mainContext
        
        if checkIfExist {
            
            let fetchDescriptor = FetchDescriptor<Medicine>(sortBy: [SortDescriptor(\Medicine.name)])
            let count = try? context.fetchCount(fetchDescriptor)
            if count ?? 0 > 0 { return }
        }
        
        createSampleSymptoms(context: context)
        createSampleMeds(context: context)
        createSampleEventsAndCategories(context: context)
        
        do {
            try context.save()
        } catch {
            let ierror = InternalError(file: "SampleData", function: "createSampleData", appError: "failure to save context after creatoing sample data", osError: error.localizedDescription)
            ErrorManager.addError(error: ierror, container: container)
        }
        
        combineData(context: context)
        
//        let fetchDescriptorC = FetchDescriptor<EventCategory>(sortBy: [SortDescriptor(\EventCategory.name)])
//        let categories = try? context.fetch(fetchDescriptorC)
//        
//        for category in categories ?? [] {
//            print(category.name)
//        }
        
    }
    
    class func combineData(context: ModelContext) {
        
        let fetchDescriptorS = FetchDescriptor<Symptom>(sortBy: [SortDescriptor(\Symptom.name)])
        let existingSymptoms = try? context.fetch(fetchDescriptorS)

        let fetchDescriptorM = FetchDescriptor<Medicine>(sortBy: [SortDescriptor(\Medicine.name)])
        let existingMedicines = try? context.fetch(fetchDescriptorM)
        
        // link Medicines and symptoms/ side effects
        guard existingSymptoms?.count ?? 0 > 0 && existingMedicines?.count ?? 0 > 0 else { return }
        for i in 0..<existingMedicines!.count {
            let symptom = existingSymptoms!.randomElement()
            if symptom!.type == SymptomType.symptom.rawValue {
                existingMedicines![i].treatedSymptoms = [symptom!]
            } else {
                existingMedicines![i].sideEffects = [symptom!]
            }
        }

    }
    
    class func createSampleMeds(context: ModelContext) {
        
        let doseIntervals: [TimeInterval] = [6*3600, 6*3600, 24*3600, 48*3600]
        let names = ["Paracetamol S", "Ibuprofen S", "Amitriptyline S", "Buprenorphine SA"]
        let doses: [[Double]] = [[1000.0, 500, 1000, 500], [400], [10], [15]]
        let units = [DoseUnit.mg.rawValue, DoseUnit.mg.rawValue, DoseUnit.mg.rawValue, DoseUnit.mcg_h.rawValue]
        
        for i in 0..<names.count {
            var medDoses = [Dose]()
            for j in 0..<doses[i].count {
                medDoses.append(Dose(unit: units[j], value1: doses[i][j]))
            }
            let start = Date().addingTimeInterval(-TimeInterval.random(in: 0...30*24*3600))
            let end = Bool.random() ? start.addingTimeInterval(TimeInterval.random(in: 0...120*24*3600)) : nil
            let new = Medicine(name: names[i], currentStatus: "Current", doses: medDoses, startDate: start, endDate: end, effectDuration: doseIntervals[i], isRegular: Bool.random())
            context.insert(new)
        }
    }
    
    class func createSampleSymptoms(context: ModelContext) {
        
        let names = ["Pain", "Stress", "Nausea"]
        let types = ["Symptom", "Symptom", "Side effect"]
        
        for i in 0..<names.count {
            let new = Symptom(name: names[i], type: types[i], creatingDevice: UIDevice.current.name)
            context.insert(new)
        }
    }
    
    class func createSampleEventsAndCategories(context: ModelContext) {
        
        let names = ["My life S", "Treatment S", "Milestone S", "Work event S"]
        var categories = [EventCategory]()
        for i in 0..<names.count {
            let color = ColorManager.getNewCategoryColor(container: context.container)
            let new = EventCategory(name: names[i], color: color)
            context.insert(new)
            categories.append(new)
        }
        
        for _ in 0..<50 {
            let date = Date().addingTimeInterval(-TimeInterval.random(in: 0...30*24*3600))
            let end = Bool.random() ? nil : date.addingTimeInterval(TimeInterval.random(in: 0...4*3600))
            let cat = categories.randomElement()!
            let new = DiaryEvent(date: date, endDate: end , category: cat)
            context.insert(new)
        }

    }
    
    
}
