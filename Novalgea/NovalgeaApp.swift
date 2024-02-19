//
//  NovalgeaApp.swift
//  Novalgea
//
//  Created by aDev on 02/02/2024.
//

import SwiftUI
import SwiftData
import OSLog

@main
struct NovalgeaApp: App {
    
    // container and init are essential for CloudKit to work; without it crashes
    var container: ModelContainer

    init() {
        do {
            let storeURL = URL.documentsDirectory.appending(path: "Novalgea.database.sqlite")
            let config3 = ModelConfiguration(url: storeURL, cloudKitDatabase: .private("iCloud.co.uk.apptoolfactory.Novalgea"))
            container = try ModelContainer(for: Symptom.self, Medicine.self, DiaryEvent.self, ExerciseEvent.self, PRNMedEvent.self, Rating.self, InternalError.self, configurations: config3)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
        
    }
    // container and init are essential for CloudKit to work

    
    var body: some Scene {

        WindowGroup {
            TabView {
                AlogeaFileImportView()
                    .tabItem {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }

                ErrorsListView()
                    .tabItem {
                        Label("Errors", systemImage: "ant.circle")
                    }

                RatingsListView()
                    .tabItem {
                        Label("Ratings", systemImage: "number.circle")
                    }
//                    .onAppear {
//                        Logger().info("Document directory at \(URL.documentsDirectory)")
//                    }
                
                MedicinesListView()
                    .tabItem {
                        Label("Medicine", systemImage: "pills.circle")
                    }

            } 
        }
        .modelContainer(container)
//        .modelContainer(for: [Symptom.self, Medicine.self, DiaryEvent.self, ExerciseEvent.self, PRNMedEvent.self, Rating.self, InternalError.self], isUndoEnabled: true)
        //        .modelContainer(DataController.samplesContainer)

    }
}

public let defaultSymptom = NSLocalizedString("defaultSymptom", comment: "")


enum User_Default_Keys: String {
    case lastLaunchedVersion = "LastLaunchedVersion"
    case selectedSymptom = "SelectedScore"
    case exerciseType = "exerciseType"
    case exerciseMetric = "exerciseMetric"
    case exerciseTarget = "exerciseTarget"
    case exerciseFrequency = "exerciseFrequency"
    case eventsNotShown = "eventsNotShown" // contains names of medsNotShown!
    case cloudBackupIsOn = "iCloudBackUpsOn"
}

