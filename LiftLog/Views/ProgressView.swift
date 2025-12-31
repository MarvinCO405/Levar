//
//  ProgressView.swift
//  LiftLog
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import SwiftUI
import SwiftData
import Charts

struct ProgressView: View {
    @Query private var exercises: [Exercise]
    @State private var selectedExercise: Exercise?
    @State private var showingExercisePicker = false
    
    var body: some View {
        NavigationStack {
            Group {
                if let exercise = selectedExercise {
                    ExerciseProgressView(exercise: exercise)
                } else {
                    EmptyProgressView(onSelectExercise: { showingExercisePicker = true })
                }
            }
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Select Exercise") {
                        showingExercisePicker = true
                    }
                }
            }
            .sheet(isPresented: $showingExercisePicker) {
                ProgressExercisePickerView(selectedExercise: $selectedExercise)
            }
        }
    }
}

struct EmptyProgressView: View {
    let onSelectExercise: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            Text("Track Your Progress")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Select an exercise to view your progress over time")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onSelectExercise) {
                Label("Select Exercise", systemImage: "dumbbell.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 8)
        }
    }
}

struct ExerciseProgressView: View {
    @Query private var allSets: [WorkoutSet]
    let exercise: Exercise
    @State private var timeRange: TimeRange = .threeMonths
    
    private var exerciseSets: [WorkoutSet] {
        let cutoffDate = Calendar.current.date(byAdding: timeRange.component, value: -timeRange.value, to: Date()) ?? Date()
        return allSets
            .filter { $0.exercise?.id == exercise.id && $0.timestamp >= cutoffDate }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    private var sessionData: [(Date, Double, Int)] {
        let grouped = Dictionary(grouping: exerciseSets) { set in
            Calendar.current.startOfDay(for: set.timestamp)
        }
        
        return grouped.map { date, sets in
            let maxWeight = sets.map { $0.weight }.max() ?? 0
            let totalVolume = sets.reduce(0) { $0 + $1.volume }
            return (date, maxWeight, Int(totalVolume))
        }.sorted { $0.0 < $1.0 }
    }
    
    private var personalRecords: PersonalRecords {
        let maxWeight = exerciseSets.map { $0.weight }.max() ?? 0
        let maxReps = exerciseSets.map { $0.reps }.max() ?? 0
        let maxVolume = sessionData.map { $0.2 }.max() ?? 0
        let totalVolume = exerciseSets.reduce(0) { $0 + $1.volume }
        let totalSets = exerciseSets.count
        
        return PersonalRecords(
            maxWeight: maxWeight,
            maxReps: maxReps,
            maxVolume: maxVolume,
            totalVolume: totalVolume,
            totalSets: totalSets
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Time Range Picker
                Picker("Time Range", selection: $timeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Personal Records Cards
                PersonalRecordsSection(records: personalRecords)
                
                if !sessionData.isEmpty {
                    // Weight Progress Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Max Weight Over Time")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart(sessionData, id: \.0) { data in
                            LineMark(
                                x: .value("Date", data.0),
                                y: .value("Weight", data.1)
                            )
                            .foregroundStyle(.blue)
                            .interpolationMethod(.catmullRom)
                            
                            PointMark(
                                x: .value("Date", data.0),
                                y: .value("Weight", data.1)
                            )
                            .foregroundStyle(.blue)
                        }
                        .frame(height: 250)
                        .padding(.horizontal)
                        .chartYAxisLabel("Weight (lbs)")
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Volume Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Training Volume")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart(sessionData, id: \.0) { data in
                            BarMark(
                                x: .value("Date", data.0),
                                y: .value("Volume", data.2)
                            )
                            .foregroundStyle(.green.gradient)
                        }
                        .frame(height: 250)
                        .padding(.horizontal)
                        .chartYAxisLabel("Volume (lbs)")
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        Text("No data for selected time range")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct PersonalRecordsSection: View {
    let records: PersonalRecords
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                RecordCard(
                    title: "Max Weight",
                    value: "\(records.maxWeight, default: "%.1f")",
                    unit: "lbs",
                    icon: "flame.fill",
                    color: .orange
                )
                
                RecordCard(
                    title: "Max Reps",
                    value: "\(records.maxReps)",
                    unit: "reps",
                    icon: "repeat",
                    color: .purple
                )
            }
            
            HStack(spacing: 12) {
                RecordCard(
                    title: "Total Volume",
                    value: "\(records.totalVolume, default: "%.0f")",
                    unit: "lbs",
                    icon: "chart.bar.fill",
                    color: .green
                )
                
                RecordCard(
                    title: "Total Sets",
                    value: "\(records.totalSets)",
                    unit: "sets",
                    icon: "number",
                    color: .blue
                )
            }
        }
        .padding(.horizontal)
    }
}

struct RecordCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct PersonalRecords {
    let maxWeight: Double
    let maxReps: Int
    let maxVolume: Int
    let totalVolume: Double
    let totalSets: Int
}

enum TimeRange: String, CaseIterable {
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case allTime = "All"
    
    var component: Calendar.Component {
        switch self {
        case .oneMonth, .threeMonths, .sixMonths: return .month
        case .oneYear: return .year
        case .allTime: return .year
        }
    }
    
    var value: Int {
        switch self {
        case .oneMonth: return 1
        case .threeMonths: return 3
        case .sixMonths: return 6
        case .oneYear: return 1
        case .allTime: return 100
        }
    }
}

struct ProgressExercisePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var exercises: [Exercise]
    @Binding var selectedExercise: Exercise?
    @State private var searchText = ""
    
    private var filteredExercises: [Exercise] {
        if searchText.isEmpty {
            return exercises.sorted { $0.name < $1.name }
        }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredExercises) { exercise in
                Button(action: {
                    selectedExercise = exercise
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: exercise.category.icon)
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text(exercise.name)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedExercise?.id == exercise.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
