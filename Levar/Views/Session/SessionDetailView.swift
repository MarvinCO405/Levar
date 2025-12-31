//
//  SessionDetailView.swift
//  Levar
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @Bindable var session: WorkoutSession
    @State private var showingAddSet = false

    var body: some View {
        List {
            if let sets = session.sets, !sets.isEmpty {
                ForEach(sets, id: \.id) { set in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(set.exercise?.name ?? "Exercise")
                                .font(.headline)
                            Text(set.timestamp, style: .time)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Reps: \(set.reps)")
                            Text("Weight: \(set.weight, format: .number.precision(.fractionLength(1)))")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteSets)
            } else {
                ContentUnavailableView("No Sets", systemImage: "dumbbell", description: Text("Add a set to this session."))
            }
        }
        .navigationTitle(session.date.formatted(date: .abbreviated, time: .shortened))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(destination: AddExerciseToSessionView(session: session)) {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Finish Workout") {
                    finishCurrentWorkout()
                }
            }
        }
        .sheet(isPresented: $showingAddSet) {
            AddSetView(session: session) { newSet in
                // Ensure relationship wiring
                newSet.session = session
                if session.sets == nil { session.sets = [] }
                session.sets?.append(newSet)
                try? context.save()
            }
        }
        
        
    }

    private func deleteSets(at offsets: IndexSet) {
        guard let sets = session.sets else { return }
        for index in offsets { context.delete(sets[index]) }
        try? context.save()
    }
    
    private func finishCurrentWorkout() {
        session.finish()   // Update isCompleted + duration

        do {
            try context.save()
            dismiss()
        } catch {
            print("Failed to save finished workout: \(error)")
        }
    }
}
