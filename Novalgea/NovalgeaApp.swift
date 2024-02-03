//
//  NovalgeaApp.swift
//  Novalgea
//
//  Created by aDev on 02/02/2024.
//

import SwiftUI

@main
struct NovalgeaApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
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

