//
//  AddExerciseToSessionView.swift
//  Levar
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import SwiftUI
import SwiftData

struct AddExerciseToSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var showingAddExercise = false
    @State private var selectedExercise: Exercise?

    let session: WorkoutSession
    
    @Query(sort: [SortDescriptor(\Exercise.name, order: .forward)])
    private var exercises: [Exercise]

    var body: some View {
        NavigationStack {
            Form {
                Section("Select Exercise") {
                    Picker("Exercise", selection: $selectedExercise) {
                        ForEach(exercises, id: \.id) { exercise in
                            Label(exercise.name, systemImage: exercise.category.icon)
                                .tag(Optional(exercise))
                        }
                    }
                    .pickerStyle(.menu)
                }

                if selectedExercise != nil {
                    NavigationLink("Add Sets", destination: AddSetsForExerciseView(session: session, exercise: selectedExercise!))
                }

                Section {
                    Button("Add New Exercise") {
                        showingAddExercise = true
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView(onAdd: { newExercise in
                    selectedExercise = newExercise
                })
            }

        }
    }
}

