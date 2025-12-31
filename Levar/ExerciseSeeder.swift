//
//  ExerciseSeeder.swift
//  Levar
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import Foundation
import SwiftData

struct ExerciseSeedDTO: Decodable {
    let name: String
    let category: String
}

enum ExerciseSeeder {

    static func seedIfNeeded(context: ModelContext) {
        // Prevent duplicate seeding
        let fetch = FetchDescriptor<Exercise>()
        let existingCount = (try? context.fetch(fetch).count) ?? 0
        guard existingCount == 0 else { return }

        guard let url = Bundle.main.url(forResource: "DefaultExercises", withExtension: "json") else {
            assertionFailure("DefaultExercises.json not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([ExerciseSeedDTO].self, from: data)

            decoded.forEach { item in
                guard let category = ExerciseCategory(rawValue: item.category) else {
                    print("⚠️ Unknown category: \(item.category)")
                    return
                }

                let exercise = Exercise(
                    name: item.name,
                    category: category,
                    notes: "",
                    isCustom: false
                )
                context.insert(exercise)
            }

            try context.save()
            print("✅ Default exercises seeded")

        } catch {
            assertionFailure("Failed to seed exercises: \(error)")
        }
    }
}
