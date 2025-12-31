//
//  LevarApp.swift
//  Levar
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import SwiftUI
import SwiftData

@main
struct LevarApp: App {
    
    let sharedModelContainer: ModelContainer

    init() {
        let schema = Schema([
            Exercise.self,
            WorkoutSet.self,
            WorkoutSession.self,
            PersonalRecord.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            sharedModelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            // ✅ Seed default exercises ONCE
            let context = ModelContext(sharedModelContainer)
            ExerciseSeeder.seedIfNeeded(context: context)

        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }


    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

