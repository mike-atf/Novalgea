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
    
    //call with '@EnvironmentObject private var appDelegate: MyAppDelegate'
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    // container and init are essential for CloudKit to work; without it crashes
    @State var container: ModelContainer = {
        do {
            let modelFolder = URL.applicationSupportDirectory.appending(path: "ModelData")
            try FileManager.default.createDirectory(at: modelFolder, withIntermediateDirectories: true)
            
            let storeURL = modelFolder.appending(path: "Novalgea.database.sqlite")
            let config = ModelConfiguration(url: storeURL, cloudKitDatabase: .private("iCloud.co.uk.apptoolfactory.Novalgea"))
            //WARNING: - Model changes must be reflected and checked against importing and replacing the modelContainer in ImportView.decompressArchive()
            return try ModelContainer(for: Symptom.self, Medicine.self, DiaryEvent.self, ExerciseEvent.self, MedicineEvent.self, Rating.self, InternalError.self, EventCategory.self, configurations: config)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }()
    // container and init are essential for CloudKit to work
    
    var body: some Scene {

        WindowGroup {
            TabView {
                GraphicDiaryView()
                    .tabItem {
                        Label("Charts", systemImage: "chart.xyaxis.line")
                    }
                ImportView(modelContainer: $container)
                    .tabItem {
                        Label("Import", systemImage: "arrow.down.app.fill")
                    }

                AlogeaFileImportView()
                    .tabItem {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }

                ErrorsListView()
                    .tabItem {
                        Label("Errors", systemImage: "ant.circle")
                    }
                SymptomsListView()
                    .tabItem {
                        Label("Symptoms", systemImage: "bolt.circle")
                    }

                RatingsListView()
                    .tabItem {
                        Label("Ratings", systemImage: "number.circle")
                    }
                
                MedicinesListView()
                    .tabItem {
                        Label("Medicine", systemImage: "pills.circle")
                    }
                CategoryListView()
                    .tabItem {
                        Label("Categories", systemImage: "line.horizontal.star.fill.line.horizontal")
                    }
                DiaryEventsListView()
                    .tabItem {
                        Label("Events", systemImage: "calendar")
                    }

                ExportView()
                    .tabItem {
                        Label("Export", systemImage: "square.and.arrow.up.on.square.fill")
                    }
                CalendarTileView()
                    .tabItem {
                        Label("Calendar", systemImage: "square.grid.3x3.square")
                    }

            }
        }
        .modelContainer(container)
//        .modelContainer(for: [Symptom.self, Medicine.self, DiaryEvent.self, ExerciseEvent.self, PRNMedEvent.self, Rating.self, InternalError.self], isUndoEnabled: true)
        //        .modelContainer(DataController.samplesContainer)

    }
    
    public mutating func resetModelContainer(to: URL) {
        do {
            let config = ModelConfiguration(url: to, cloudKitDatabase: .private("iCloud.co.uk.apptoolfactory.Novalgea"))
            self.container = try ModelContainer(for: Symptom.self, Medicine.self, DiaryEvent.self, ExerciseEvent.self, MedicineEvent.self, Rating.self, InternalError.self, EventCategory.self, configurations: config)
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }

    }
}

public let defaultSymptom = UserText.term("defaultSymptom")


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

