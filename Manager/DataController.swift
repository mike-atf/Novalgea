//
//  DataController.swift
//  Novalgea
//
//  Created by aDev on 07/02/2024.
//  provided by HackingWithSwift


import SwiftData

actor DataController {
        
    @MainActor
    static var previewContainer: ModelContainer = {
        
        let schema = Schema([Medicine.self, DiaryEvent.self, ExerciseEvent.self, PRNMedEvent.self, Rating.self, Symptom.self, InternalError.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        
        let sampleData: [any PersistentModel] = [
            Medicine.preview, DiaryEvent.preview, ExerciseEvent.preview, PRNMedEvent.preview, Rating.preview, Symptom.preview, InternalError.preview
        ]
        Task { @MainActor in
            sampleData.forEach {
                container.mainContext.insert($0)
            }
        }

        return container
    }()

//    static var inMemoryContainer: () throws -> ModelContainer = {
//        let schema = Schema([Medicine.self], DiaryEvent.self, ExerciseEvent.self, PRNMedEvent.self, Rating.self, Symptom.self, InternalError.self)
//        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
//        let container = try! ModelContainer(for: schema, configurations: [configuration])
//        
//        let sampleData: [any PersistentModel] = [
//            Medicine.preview, DiaryEvent.preview, ExerciseEvent.preview, PRNMedEvent.preview, Rating.preview, Symptom.preview, InternalError.preview
//        ]
//        Task { @MainActor in
//            sampleData.forEach {
//                container.mainContext.insert($0)
//            }
//        }
//        return container
//    }

//    static let previewContainer: ModelContainer = {
//        do {
//            let schema = Schema( [Medicine.self]) // , DiaryEvent.self, ExerciseEvent.self, PRNMedEvent.self, Rating.self, Symptom.self, InternalError.self
//            let config = ModelConfiguration(isStoredInMemoryOnly: true)
//            let container = try! ModelContainer(for: schema, configurations: config)
//
//            let names = ["Paracetamol", "Codeine phosphate", "Naproxen", "Buprenorphine", "Nefopam", "Amitriptyline", "Diazepam", "Ibuprofen", "Gabapentin", "Placebo"]
//            
//            for i in 0...9 {
//                let sampleMedicine = Medicine(name: names[i])
//                container.mainContext.insert(sampleMedicine)
//            }
//
//            return container
//        } catch {
//            print("Failed to create model container for previewing: \(error.localizedDescription)")
//        }
//    }()
}


