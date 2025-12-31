//
//  HistoryView.swift
//  LiftLog
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \WorkoutSession.date, order: .reverse) private var sessions: [WorkoutSession]

    private var completedSessions: [WorkoutSession] {
        sessions.filter { $0.isCompleted }
    }
    
    private var groupedSessions: [(String, [WorkoutSession])] {
        let grouped = Dictionary(grouping: completedSessions) { session in
            formatMonthYear(session.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if completedSessions.isEmpty {
                    EmptyHistoryView()
                } else {
                    List {
                        ForEach(groupedSessions, id: \.0) { month, sessions in
                            Section(month) {
                                ForEach(sessions) { session in
                                    NavigationLink(destination: WorkoutDetailView(session: session)) {
                                        WorkoutSessionRow(session: session)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
    
    private func formatMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            Text("No Workout History")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Complete your first workout to see it here")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct WorkoutSessionRow: View {
    let session: WorkoutSession
    
    private var uniqueExercises: Set<String> {
        Set(session.sets?.compactMap { $0.exercise?.name } ?? [])
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.date, style: .date)
                    .font(.headline)
                Spacer()
                Text(formatDuration(session.duration))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 16) {
                Label("\(session.totalSets)", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label("\(uniqueExercises.count)", systemImage: "dumbbell.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label("\(Int(session.totalVolume))", systemImage: "chart.bar.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if !uniqueExercises.isEmpty {
                Text(Array(uniqueExercises).prefix(3).joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var session: WorkoutSession
    @State private var showingDeleteAlert = false
    
    private var groupedSets: [(Exercise, [WorkoutSet])] {
        let sets = session.sets ?? []
        let grouped = Dictionary(grouping: sets) { $0.exercise }
        return grouped.compactMap { exercise, sets in
            guard let exercise = exercise else { return nil }
            return (exercise, sets.sorted { $0.timestamp < $1.timestamp })
        }.sorted { $0.0.name < $1.0.name }
    }
    
    var body: some View {
        List {
            Section("Workout Summary") {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(session.date, style: .date)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Duration")
                    Spacer()
                    Text(formatDuration(session.duration))
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Total Sets")
                    Spacer()
                    Text("\(session.totalSets)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Exercises")
                    Spacer()
                    Text("\(session.exerciseCount)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Total Volume")
                    Spacer()
                    Text("\(session.totalVolume, specifier: "%.0f") lbs")
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                }
            }
            
            if !session.notes.isEmpty {
                Section("Notes") {
                    Text(session.notes)
                }
            }
            
            ForEach(groupedSets, id: \.0.id) { exercise, sets in
                Section(exercise.name) {
                    ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                        HStack {
                            Text("Set \(index + 1)")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(set.weight, specifier: "%.1f") lbs × \(set.reps) reps")
                                .fontWeight(.medium)
                            if set.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }
                        }
                        
                        if !set.notes.isEmpty {
                            Text(set.notes)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Delete Workout", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteWorkout()
            }
        } message: {
            Text("Are you sure you want to delete this workout? This action cannot be undone.")
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours) hour\(hours == 1 ? "" : "s") \(minutes) minute\(minutes == 1 ? "" : "s")"
        } else {
            return "\(minutes) minute\(minutes == 1 ? "" : "s")"
        }
    }
    
    private func deleteWorkout() {
        modelContext.delete(session)
    }
}
