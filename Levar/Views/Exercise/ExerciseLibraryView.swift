//
//  ExerciseLibraryView.swift
//  LiftLog
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import SwiftUI
import SwiftData

struct ExerciseLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var exercises: [Exercise]
    @State private var searchText = ""
    @State private var selectedCategory: ExerciseCategory?
    @State private var showingAddExercise = false
    
    private var filteredExercises: [Exercise] {
        exercises.filter { exercise in
            let matchesSearch = searchText.isEmpty || exercise.name.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || exercise.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }
    
    private var groupedExercises: [(ExerciseCategory, [Exercise])] {
        let grouped = Dictionary(grouping: filteredExercises) { $0.category }
        return grouped.map { ($0.key, $0.value.sorted { $0.name < $1.name }) }
            .sorted { $0.0.rawValue < $1.0.rawValue }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryFilterButton(
                            title: "All",
                            isSelected: selectedCategory == nil,
                            action: { selectedCategory = nil }
                        )
                        
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                title: category.rawValue,
                                isSelected: selectedCategory == category,
                                action: { selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGroupedBackground))
                
                List {
                    ForEach(groupedExercises, id: \.0) { category, exercises in
                        Section(category.rawValue) {
                            ForEach(exercises) { exercise in
                                NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
                                    ExerciseRow(exercise: exercise)
                                }
                            }
                            .onDelete { indexSet in
                                deleteExercises(at: indexSet, in: exercises)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search exercises")
            }
            .navigationTitle("Exercise Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingAddExercise = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExercise) {
                AddExerciseView()
            }
        }
    }
    
    private func deleteExercises(at offsets: IndexSet, in exercises: [Exercise]) {
        for index in offsets {
            let exercise = exercises[index]
            // Only allow deleting custom exercises
            if exercise.isCustom {
                modelContext.delete(exercise)
            }
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            Image(systemName: exercise.category.icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.body)
                
                if !exercise.notes.isEmpty {
                    Text(exercise.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if exercise.isCustom {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
    }
}

struct ExerciseDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allSets: [WorkoutSet]
    let exercise: Exercise
    
    private var exerciseSets: [WorkoutSet] {
        allSets.filter { $0.exercise?.id == exercise.id }
            .sorted { $0.timestamp > $1.timestamp }
    }
    
    private var totalVolume: Double {
        exerciseSets.reduce(0) { $0 + $1.volume }
    }
    
    private var maxWeight: Double {
        exerciseSets.map { $0.weight }.max() ?? 0
    }
    
    private var totalReps: Int {
        exerciseSets.reduce(0) { $0 + $1.reps }
    }
    
    var body: some View {
        List {
            Section("Information") {
                HStack {
                    Text("Category")
                    Spacer()
                    Text(exercise.category.rawValue)
                        .foregroundStyle(.secondary)
                }
                
                if !exercise.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notes")
                            .font(.subheadline)
                        Text(exercise.notes)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Statistics") {
                StatRow(label: "Total Sets", value: "\(exerciseSets.count)")
                StatRow(label: "Total Reps", value: "\(totalReps)")
                StatRow(label: "Max Weight", value: "\(maxWeight, default: "%.1f") lbs")
                StatRow(label: "Total Volume", value: "\(totalVolume, default: "%.0f") lbs")
            }
            
            if !exerciseSets.isEmpty {
                Section("Recent Sets") {
                    ForEach(exerciseSets.prefix(10)) { set in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(set.timestamp, style: .date)
                                    .font(.subheadline)
                                Text(set.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(set.weight, specifier: "%.1f") lbs × \(set.reps)")
                                .font(.body)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .fontWeight(.medium)
        }
    }
}



struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : .primary)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
        }
        .buttonStyle(.plain)
    }
}
