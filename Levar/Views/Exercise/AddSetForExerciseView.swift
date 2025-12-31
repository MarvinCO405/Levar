//
//  AddSetForExerciseView.swift
//  Levar
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import SwiftUI
import SwiftData

struct AddSetsForExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    let session: WorkoutSession
    let exercise: Exercise
    
    @State private var sets: [WorkoutSet] = []

    @State private var reps: Int = 8
    @State private var weight: Double = 135
    @State private var notes: String = ""

    var body: some View {
        Form {
            Section("New Set") {
                Stepper("Reps: \(reps)", value: $reps, in: 1...100)
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
                
                Button("Add Set") {
                    let newSet = WorkoutSet(reps: reps, weight: weight, isCompleted: true, notes: notes)
                    newSet.exercise = exercise
                    if session.sets == nil { session.sets = [] }
                    session.sets?.append(newSet)
                    sets.append(newSet)
                    
                    // Reset fields for next set
                    reps = 8
                    weight = 135
                    notes = ""
                    
                    try? context.save()
                }
            }

            if !sets.isEmpty {
                Section("Sets Added") {
                    ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                        Text("Set \(index + 1): \(set.weight, specifier: "%.1f") lbs × \(set.reps) reps")
                    }
                }
            }
        }
        .navigationTitle(exercise.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

