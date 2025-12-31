//
//  LiftLogApp.swift
//  LiftLog
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import SwiftUI
import SwiftData

@main
struct LiftLogApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Exercise.self,
            WorkoutSet.self,
            WorkoutSession.self,
            PersonalRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

