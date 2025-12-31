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

struct SessionsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\WorkoutSession.date, order: .reverse)])
    private var sessions: [WorkoutSession]

    @State private var showingAddSession = false

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    ContentUnavailableView(
                        "No Sessions",
                        systemImage: "figure.strengthtraining.traditional",
                        description: Text("Add your first workout session to get started.")
                    )
                } else {
                    List {
                        ForEach(sessions, id: \.id) { session in
                            NavigationLink(destination: SessionDetailView(session: session)) {
                                SessionRow(session: session)
                            }
                        }
                        .onDelete(perform: deleteSessions)
                    }
                }
            }
            .navigationTitle("LiftLog")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { EditButton() }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSession = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityLabel("Add session")
                }
            }
            .sheet(isPresented: $showingAddSession) {
                AddSessionView { date, notes in
                    let new = WorkoutSession(date: date, notes: notes)
                    context.insert(new)
                    try? context.save()
                }
            }
        }
    }

    private func deleteSessions(at offsets: IndexSet) {
        for index in offsets { context.delete(sessions[index]) }
        try? context.save()
    }
}

private struct SessionRow: View {
    let session: WorkoutSession

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(session.date, style: .date)
                Text(session.date, style: .time)
            }
            .font(.headline)

            HStack(spacing: 12) {
                Label("\(session.totalSets)", systemImage: "number").labelStyle(.titleAndIcon)
                Label("\(session.exerciseCount)", systemImage: "dumbbell").labelStyle(.titleAndIcon)
                Label {
                    Text(session.totalVolume, format: .number.precision(.fractionLength(0)))
                } icon: {
                    Image(systemName: "scalemass")
                }
                .labelStyle(.titleAndIcon)
                .symbolEffect(.pulse, value: session.totalVolume)
            }
            .font(.footnote)
            .foregroundStyle(.secondary)

            if !session.notes.isEmpty {
                Text(session.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct SessionDetailView: View {
    @Environment(\.modelContext) private var context

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
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddSet = true
                } label: {
                    Image(systemName: "plus")
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
                        HStack {
                            Image(systemName: exercise.category.icon)
                            Text(exercise.name)
                        }
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

#Preview("ContentView") {
    ContentView()
        .modelContainer(for: [Exercise.self, WorkoutSet.self, WorkoutSession.self, PersonalRecord.self], inMemory: true)
}

