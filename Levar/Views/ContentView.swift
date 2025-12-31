// Legacy template ContentView shim to avoid duplicate types.
// This file intentionally redirects to the new SwiftData-powered ContentView.
import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            SessionsView()
                .tabItem {
                    Label("Sessions", systemImage: "list.bullet.rectangle")
                }
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
            ProgressScreen()
                .tabItem {
                    Label("Progress", systemImage: "chart.xyaxis.line")
                }
            ExerciseLibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
        }
    }
}



struct AddSessionView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var date: Date = .now
    @State private var notes: String = ""

    var onAdd: (Date, String) -> Void

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
            }
            .navigationTitle("New Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onAdd(date, notes)
                        dismiss()
                    }
                }
            }
        }
    }
}


#Preview("ContentView") {
    ContentView()
        .modelContainer(for: [Exercise.self, WorkoutSet.self, WorkoutSession.self, PersonalRecord.self], inMemory: true)
}

