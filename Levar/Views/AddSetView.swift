//
//  AddSetView.swift
//  Levar
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import SwiftUI
import SwiftData

struct AddSetView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let session: WorkoutSession
    var onAdd: (WorkoutSet) -> Void

    @Query(sort: [SortDescriptor(\Exercise.dateCreated, order: .reverse)])
    private var exercises: [Exercise]

    @State private var selectedExercise: Exercise?
    @State private var reps: Int = 8
    @State private var weight: Double = 135
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Exercise", selection: $selectedExercise) {
                    ForEach(exercises, id: \.id) { exercise in
                        Label(exercise.name, systemImage: exercise.category.icon)
                            .tag(Optional(exercise))
                    }
                }
                Stepper(value: $reps, in: 1...100) {
                    HStack {
                        Text("Reps")
                        Spacer()
                        Text("\(reps)")
                    }
                }
                HStack {
                    Text("Weight")
                    Spacer()
                    TextField("lbs", value: $weight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 120)
                }
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)

                if exercises.isEmpty {
                    Section {
                        Text("No exercises yet. Add some defaults?")
                        Button("Add sample exercises", action: addSampleExercises)
                    }
                }
            }
            .navigationTitle("New Set")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let set = WorkoutSet(reps: reps, weight: weight, isCompleted: true, notes: notes)
                        set.exercise = selectedExercise
                        onAdd(set)
                        dismiss()
                    }
                    .disabled(selectedExercise == nil)
                }
            }
        }
        .onAppear {
            if selectedExercise == nil { selectedExercise = exercises.first }
        }
    }

    private func addSampleExercises() {
        let samples: [Exercise] = [
            Exercise(name: "Bench Press", category: .chest),
            Exercise(name: "Deadlift", category: .back),
            Exercise(name: "Squat", category: .legs),
            Exercise(name: "Overhead Press", category: .shoulders)
        ]
        samples.forEach(context.insert)
        try? context.save()
    }
}

