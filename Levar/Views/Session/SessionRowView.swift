//
//  SessionRow.swift
//  Levar
//
//  Created by Marvin Cordova Ortiz on 1/1/26.
//

import SwiftUI
import SwiftData

private struct SessionRowView: View {
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


