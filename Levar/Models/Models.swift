//
//  Models.swift
//  Levar
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var category: ExerciseCategory
    var notes: String
    var dateCreated: Date
    var isCustom: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var sets: [WorkoutSet]?
    
    init(name: String, category: ExerciseCategory, notes: String = "", isCustom: Bool = false) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.notes = notes
        self.dateCreated = Date()
        self.isCustom = isCustom
        self.sets = []
    }
}

enum ExerciseCategory: String, Codable, CaseIterable {
    case chest = "Chest"
    case back = "Back"
    case legs = "Legs"
    case shoulders = "Shoulders"
    case arms = "Arms"
    case core = "Core"
    case cardio = "Cardio"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.rowing"
        case .legs: return "figure.walk"
        case .shoulders: return "figure.arms.open"
        case .arms: return "hand.raised.fill"
        case .core: return "figure.core.training"
        case .cardio: return "heart.fill"
        case .other: return "star.fill"
        }
    }
}

@Model
final class WorkoutSet {
    var id: UUID
    var reps: Int
    var weight: Double
    var isCompleted: Bool
    var timestamp: Date
    var notes: String
    
    var exercise: Exercise?
    var session: WorkoutSession?
    
    init(reps: Int, weight: Double, isCompleted: Bool = false, notes: String = "") {
        self.id = UUID()
        self.reps = reps
        self.weight = weight
        self.isCompleted = isCompleted
        self.timestamp = Date()
        self.notes = notes
    }
    
    var volume: Double {
        return weight * Double(reps)
    }
}

// MARK: - Workout Session Model
@Model
final class WorkoutSession {
    var id: UUID
    var date: Date
    var duration: TimeInterval
    var notes: String
    var isCompleted: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.session)
    var sets: [WorkoutSet]?
    
    init(date: Date = Date(), notes: String = "") {
        self.id = UUID()
        self.date = date
        self.duration = 0
        self.notes = notes
        self.isCompleted = false
        self.sets = []
    }
    
    var totalVolume: Double {
        return sets?.reduce(0) { $0 + $1.volume } ?? 0
    }
    
    var totalSets: Int {
        return sets?.count ?? 0
    }
    
    var exerciseCount: Int {
        let uniqueExercises = Set(sets?.compactMap { $0.exercise?.id } ?? [])
        return uniqueExercises.count
    }
    
    func finish() {
        guard !isCompleted else { return } // Prevent finishing twice

        isCompleted = true

        // Calculate duration based on first and last set timestamps if available
        if let sets = sets, let first = sets.first?.timestamp, let last = sets.last?.timestamp {
            duration = last.timeIntervalSince(first)
        } else {
            // Fallback: zero duration
            duration = 0
        }
    }
}

// MARK: - Personal Record Model
@Model
final class PersonalRecord {
    var id: UUID
    var exerciseId: UUID
    var exerciseName: String
    var weight: Double
    var reps: Int
    var date: Date
    var recordType: RecordType
    
    init(exerciseId: UUID, exerciseName: String, weight: Double, reps: Int, recordType: RecordType) {
        self.id = UUID()
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.weight = weight
        self.reps = reps
        self.date = Date()
        self.recordType = recordType
    }
}

enum RecordType: String, Codable {
    case oneRepMax = "1RM"
    case maxWeight = "Max Weight"
    case maxVolume = "Max Volume"
    case maxReps = "Max Reps"
}
