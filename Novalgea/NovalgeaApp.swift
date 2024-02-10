//
//  NovalgeaApp.swift
//  Novalgea
//
//  Created by aDev on 02/02/2024.
//

import SwiftUI
import SwiftData

@main
struct NovalgeaApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Medicine.self, DiaryEvent.self, ExerciseEvent.self, PRNMedEvent.self, Rating.self, Symptom.self, InternalError.self], isUndoEnabled: true)
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

