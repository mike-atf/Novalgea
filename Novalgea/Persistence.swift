//
//  Persistence.swift
//  Novalgea
//
//  Created by aDev on 02/02/2024.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let symptom = Symptom(context: viewContext)
        symptom.setDefaults()
        symptom.name = "Pain"
        symptom.creatingDevice = "Test device"
        
        
        let symptom2 = Symptom(context: viewContext)
        symptom.setDefaults()
        symptom2.name = "Another symptom"
        symptom2.creatingDevice = "Test device"
 
        for i in 0..<10 {
            
            let randomTime = TimeInterval.random(in: 0...365*24*3600)
            
            let medicine = Medicine(context: viewContext)
            medicine.setDefaults()
            medicine.startDate = Date().addingTimeInterval(-randomTime)
            
            if i == 2 {
                medicine.addToTreatedSymptoms(symptom)
            }
            
            if i == 3 {
                medicine.addToTreatedSymptoms(symptom2)
            }
        
            if i<2 {
                medicine.doses = [Dose(unit: .mg, value: 100),Dose(unit: .mg, value: 50),Dose(unit: .mg, value: 100)]
                medicine.effectDuration = 8*3600
                medicine.ratingRemindersOn = true
                medicine.takingRemindersOn = true
                medicine.isRegular = true
           } else if i < 4 {
               medicine.effect = MedicineEffect.moderate.rawValue
               medicine.doses = [Dose(unit: .mg, value: 75),Dose(unit: .mg, value: 75)]
               medicine.effectDuration = 12*3600
               medicine.isRegular = false
               medicine.ratingRemindersOn = false
            } else if i < 6 {
                medicine.effect = MedicineEffect.minimal.rawValue
                medicine.doses = [Dose(unit: .mg, value: 250)]
                medicine.effectDuration = 24*3600
                medicine.isRegular = false
                medicine.ratingRemindersOn = true
            } else if i < 8 {
                medicine.doses = [Dose(unit: .mg, value: 20)]
                medicine.effectDuration = 72*3600
                medicine.ratingRemindersOn = true
                medicine.takingRemindersOn = true
                medicine.isRegular = true
            } else {
                medicine.doses = [Dose(unit: .mg, value: 1000)]
                medicine.effectDuration = 24*3600
                medicine.ratingRemindersOn = false
                medicine.takingRemindersOn = false
                medicine.isRegular = true
            }
            
            //TODO: - consider alternative methods to determine current status
//            if i < 6 { medicine.currentStatus = medicine_current }
//            else { medicine.currentStatus = medicine_ended }
        }
        
        for i in 0..<250 {
            let rating = Rating(context: viewContext)
            rating.date = Date().addingTimeInterval(-TimeInterval.random(in: 60..<185*24*3600))
            rating.vas = Double.random(in: 0...10.0)
            rating.uuid = UUID()
            rating.note = String()
            if i < 125 {
                symptom.addToRatingEvents(rating)
            } else {
                symptom2.addToRatingEvents(rating)
            }
        }
        
        for i in 0..<400 {
            
            let categories = ["Milestone", "Travel", "Stress"]
            let event = DiaryEvent(context: viewContext)
            event.setDefaults()
            event.date = Date().addingTimeInterval(-TimeInterval.random(in: 60..<185*24*3600))
            event.category = categories[Int.random(in: 0..<categories.count)]
            event.notes = "Event notes \(i)"
            event.endDate = Bool.random() ? event.date.addingTimeInterval(TimeInterval.random(in: 0...4*3600)) : nil
            
        }
        
        for i in 0..<100 {
            
            let categories = ["Walk", "Swim", "Yoga"]
            let event = ExerciseEvent(context: viewContext)
            event.startDate = Date().addingTimeInterval(-TimeInterval.random(in: 60..<185*24*3600))
            event.exerciseName = categories[Int.random(in: 0..<categories.count)]
            event.value = Double.random(in: 0...1000)
            event.unit = Bool.random() ? "steps" : "minutes"
            event.endDate = event.startDate.addingTimeInterval(TimeInterval.random(in: 0...3600))
            event.uuid = UUID()
        }

        
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Novalgea")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
