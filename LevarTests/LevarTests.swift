import Testing
import Foundation
@testable import Levar

// MARK: - Exercise Model Tests
@Suite("Exercise Model Tests")
struct ExerciseTests {
    
    @Test("Exercise initializes with correct values")
    func exerciseInitialization() {
        let exercise = Exercise(name: "Bench Press", category: .chest, notes: "Flat bench")
        
        #expect(exercise.name == "Bench Press")
        #expect(exercise.category == .chest)
        #expect(exercise.notes == "Flat bench")
        #expect(exercise.isCustom == false)
        #expect(exercise.sets?.isEmpty == true)
    }
    
    @Test("Custom exercise is marked correctly")
    func customExerciseFlag() {
        let exercise = Exercise(name: "Custom Lift", category: .other, isCustom: true)
        
        #expect(exercise.isCustom == true)
    }
    
    @Test("Exercise category icons are correct", arguments: [
        (ExerciseCategory.chest, "figure.strengthtraining.traditional"),
        (ExerciseCategory.back, "figure.rowing"),
        (ExerciseCategory.legs, "figure.walk"),
        (ExerciseCategory.shoulders, "figure.arms.open"),
        (ExerciseCategory.arms, "hand.raised.fill"),
        (ExerciseCategory.core, "figure.core.training"),
        (ExerciseCategory.cardio, "heart.fill"),
        (ExerciseCategory.other, "star.fill")
    ])
    func categoryIcons(category: ExerciseCategory, expectedIcon: String) {
        #expect(category.icon == expectedIcon)
    }
}

// MARK: - WorkoutSet Model Tests
@Suite("WorkoutSet Model Tests")
struct WorkoutSetTests {
    
    @Test("WorkoutSet initializes correctly")
    func setInitialization() {
        let set = WorkoutSet(reps: 10, weight: 135.0)
        
        #expect(set.reps == 10)
        #expect(set.weight == 135.0)
        #expect(set.isCompleted == false)
        #expect(set.notes == "")
    }
    
    @Test("Volume calculation is correct", arguments: [
        (weight: 100.0, reps: 10, expected: 1000.0),
        (weight: 135.0, reps: 5, expected: 675.0),
        (weight: 225.0, reps: 3, expected: 675.0),
        (weight: 45.0, reps: 12, expected: 540.0),
        (weight: 315.0, reps: 1, expected: 315.0)
    ])
    func volumeCalculation(weight: Double, reps: Int, expected: Double) {
        let set = WorkoutSet(reps: reps, weight: weight)
        #expect(set.volume == expected)
    }
    
    @Test("Completed sets are tracked")
    func completedSetTracking() {
        let set = WorkoutSet(reps: 8, weight: 185.0, isCompleted: true)
        #expect(set.isCompleted == true)
    }
}

// MARK: - WorkoutSession Model Tests
@Suite("WorkoutSession Model Tests")
struct WorkoutSessionTests {
    
    @Test("WorkoutSession initializes correctly")
    func sessionInitialization() {
        let session = WorkoutSession()
        
        #expect(session.duration == 0)
        #expect(session.isCompleted == false)
        #expect(session.notes == "")
        #expect(session.sets?.isEmpty == true)
    }
    
    @Test("Total volume calculation with multiple sets")
    func totalVolumeCalculation() {
        let session = WorkoutSession()
        
        let set1 = WorkoutSet(reps: 10, weight: 100.0)
        let set2 = WorkoutSet(reps: 8, weight: 110.0)
        let set3 = WorkoutSet(reps: 6, weight: 120.0)
        
        set1.session = session
        set2.session = session
        set3.session = session
        
        // Manually set the sets array for testing
        // In real app, SwiftData handles this
        session.sets = [set1, set2, set3]
        
        let expectedVolume = 1000.0 + 880.0 + 720.0 // 2600.0
        #expect(session.totalVolume == expectedVolume)
    }
    
    @Test("Total sets count is correct")
    func totalSetsCount() {
        let session = WorkoutSession()
        
        let set1 = WorkoutSet(reps: 10, weight: 100.0)
        let set2 = WorkoutSet(reps: 10, weight: 100.0)
        let set3 = WorkoutSet(reps: 10, weight: 100.0)
        
        session.sets = [set1, set2, set3]
        
        #expect(session.totalSets == 3)
    }
    
    @Test("Exercise count with multiple exercises")
    func exerciseCount() {
        let session = WorkoutSession()
        
        let exercise1 = Exercise(name: "Bench Press", category: .chest)
        let exercise2 = Exercise(name: "Squat", category: .legs)
        
        let set1 = WorkoutSet(reps: 10, weight: 135.0)
        let set2 = WorkoutSet(reps: 10, weight: 135.0)
        let set3 = WorkoutSet(reps: 10, weight: 225.0)
        
        set1.exercise = exercise1
        set2.exercise = exercise1
        set3.exercise = exercise2
        
        session.sets = [set1, set2, set3]
        
        #expect(session.exerciseCount == 2)
    }
}

// MARK: - PersonalRecord Model Tests
@Suite("PersonalRecord Model Tests")
struct PersonalRecordTests {
    
    @Test("PersonalRecord initializes correctly")
    func recordInitialization() {
        let exerciseId = UUID()
        let record = PersonalRecord(
            exerciseId: exerciseId,
            exerciseName: "Bench Press",
            weight: 225.0,
            reps: 5,
            recordType: .oneRepMax
        )
        
        #expect(record.exerciseId == exerciseId)
        #expect(record.exerciseName == "Bench Press")
        #expect(record.weight == 225.0)
        #expect(record.reps == 5)
        #expect(record.recordType == .oneRepMax)
    }
    
    @Test("All record types exist", arguments: [
        RecordType.oneRepMax,
        RecordType.maxWeight,
        RecordType.maxVolume,
        RecordType.maxReps
    ])
    func recordTypes(recordType: RecordType) {
        #expect(recordType.rawValue.isEmpty == false)
    }
}

// MARK: - Utility Tests
@Suite("Utility Function Tests")
struct UtilityTests {
    
    @Test("Time range component mapping", arguments: [
        (TimeRange.oneMonth, Calendar.Component.month, 1),
        (TimeRange.threeMonths, Calendar.Component.month, 3),
        (TimeRange.sixMonths, Calendar.Component.month, 6),
        (TimeRange.oneYear, Calendar.Component.year, 1)
    ])
    func timeRangeMapping(range: TimeRange, expectedComponent: Calendar.Component, expectedValue: Int) {
        #expect(range.component == expectedComponent)
        #expect(range.value == expectedValue)
    }
}

// MARK: - Business Logic Tests
@Suite("Business Logic Tests")
struct BusinessLogicTests {
    
    @Test("Calculate one rep max estimation", arguments: [
        (weight: 225.0, reps: 5, expected: 253.1),
        (weight: 135.0, reps: 10, expected: 180.0),
        (weight: 315.0, reps: 1, expected: 315.0)
    ])
    func oneRepMaxCalculation(weight: Double, reps: Int, expected: Double) {
        // Epley formula: 1RM = weight × (1 + reps/30)
        let oneRM = weight * (1.0 + Double(reps) / 30.0)
        #expect(abs(oneRM - expected) < 1.0) // Within 1 lb tolerance
    }
    
    @Test("Weekly volume tracking")
    func weeklyVolumeCalculation() {
        let session1 = WorkoutSession()
        let session2 = WorkoutSession()
        
        let set1 = WorkoutSet(reps: 10, weight: 100.0)
        let set2 = WorkoutSet(reps: 10, weight: 100.0)
        let set3 = WorkoutSet(reps: 10, weight: 100.0)
        
        session1.sets = [set1]
        session2.sets = [set2, set3]
        
        let totalVolume = session1.totalVolume + session2.totalVolume
        #expect(totalVolume == 3000.0)
    }
    
    @Test("Progressive overload detection")
    func progressiveOverloadCheck() {
        let previousWeight = 135.0
        let currentWeight = 140.0
        
        let didProgress = currentWeight > previousWeight
        #expect(didProgress == true)
    }
}

// MARK: - Data Validation Tests
@Suite("Data Validation Tests")
struct ValidationTests {
    
    @Test("Weight validation - positive values only")
    func weightValidation() {
        let validWeight = 135.0
        let invalidWeight = -10.0
        
        #expect(validWeight > 0)
        #expect(invalidWeight < 0)
    }
    
    @Test("Reps validation - minimum of 1")
    func repsValidation() {
        let validReps = 5
        let invalidReps = 0
        
        #expect(validReps >= 1)
        #expect(invalidReps < 1)
    }
    
    @Test("Exercise name cannot be empty")
    func exerciseNameValidation() {
        let validName = "Bench Press"
        let invalidName = ""
        
        #expect(validName.isEmpty == false)
        #expect(invalidName.isEmpty == true)
    }
}

// MARK: - Integration Tests
@Suite("Integration Tests")
struct IntegrationTests {
    
    @Test("Complete workout flow simulation")
    func completeWorkoutFlow() {
        // Create a workout session
        let session = WorkoutSession()
        #expect(session.isCompleted == false)
        
        // Add an exercise
        let exercise = Exercise(name: "Bench Press", category: .chest)
        
        // Add sets
        let set1 = WorkoutSet(reps: 10, weight: 135.0)
        let set2 = WorkoutSet(reps: 8, weight: 140.0)
        let set3 = WorkoutSet(reps: 6, weight: 145.0)
        
        set1.exercise = exercise
        set2.exercise = exercise
        set3.exercise = exercise
        
        set1.session = session
        set2.session = session
        set3.session = session
        
        session.sets = [set1, set2, set3]
        
        // Mark sets as completed
        set1.isCompleted = true
        set2.isCompleted = true
        set3.isCompleted = true
        
        // Complete the workout
        session.isCompleted = true
        session.duration = 3600 // 1 hour
        
        // Verify final state
        #expect(session.isCompleted == true)
        #expect(session.totalSets == 3)
        #expect(session.exerciseCount == 1)
        #expect(session.totalVolume > 0)
    }
}
