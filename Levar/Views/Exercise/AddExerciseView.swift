//
//  AddExerciseView.swift
//  Levar
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedCategory: ExerciseCategory = .other
    @State private var notes = ""
    
    // Add this closure
    var onAdd: ((Exercise) -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Exercise Details") {
                    TextField("Exercise Name", text: $name)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ExerciseCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
                
                Section("Notes (Optional)") {
                    TextField("Add notes or instructions", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveExercise() }
                        .fontWeight(.semibold)
                        .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveExercise() {
        let newExercise = Exercise(
            name: name,
            category: selectedCategory,
            notes: notes,
            isCustom: true
        )
        
        modelContext.insert(newExercise)
        
        do {
            try modelContext.save()
            // Call the closure if parent wants to know
            onAdd?(newExercise)
            dismiss()
        } catch {
            print("Error saving exercise: \(error)")
        }
    }
}

