//
//  ContentView.swift
//  Example
//
//  Created by Yefga on 30/07/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ViewModel
    let kanji: String

    var body: some View {
        VStack {
            if let detail = viewModel.detail {
                VStack(spacing: 16) {
                    Text(detail.kanji ?? "")
                        .font(.system(size: 100, weight: .bold))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stroke Count: \(detail.strokeCount ?? 0)")
                        Text("Meanings: \(detail.meanings?.joined(separator: ", ") ?? "")")
                        Text("Name Readings: \(detail.nameReadings?.joined(separator: ", ") ?? "")")
                        Text("JLPT: \(detail.jlpt ?? 0)")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .padding()
            } else if let error = viewModel.error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ProgressView("Loading...")
            }
        }
        .navigationTitle("Kanji: \(kanji)")
        .task {
            await viewModel.load(kanji: kanji)
        }
    }
}
