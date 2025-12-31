//
//  SessionView.swift
//  Levar
//
//  Created by Marvin Cordova Ortiz on 12/31/25.
//

import SwiftUI
import SwiftData

struct SessionsView: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: [SortDescriptor(\WorkoutSession.date, order: .reverse)])
    private var sessions: [WorkoutSession]
    
    private var activeSessions: [WorkoutSession] {
        sessions.filter {!$0.isCompleted}
    }

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
                        ForEach(activeSessions, id: \.id) { session in
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

