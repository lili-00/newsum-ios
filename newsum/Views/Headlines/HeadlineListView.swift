//
//  HeadlineListView.swift
//  newsum
//
//  Created by Li Li on 4/20/25.
//

import Foundation
import SwiftUI

struct HeadlineListView: View {
    // Use @StateObject to create and manage the ViewModel instance for this view
    @StateObject private var viewModel = HeadlineViewModel()
    @State private var showingInfoSheet = false

    // You might need state for sheet presentation if adding toolbars like MainContentView
    // @State private var showingInfoSheet = false
    
    init() {
        print("+++ HeadlineListView INIT +++") // <-- Add this
    }

    var body: some View {
        // Use NavigationView to enable NavigationLink and title
        NavigationView {
            VStack { // Group helps manage conditional content
                if viewModel.isLoading && viewModel.headlines.isEmpty {
                    // Show loading indicator only on initial load
                    ProgressView("Fetching headlines...")
                } else if let errorMessage = viewModel.errorMessage {
                    // Show error message and retry button
                    ErrorView(errorMessage: errorMessage) {
                        // Retry action
                        Task {
                            await viewModel.loadHeadlines()
                        }
                    }
                } else if viewModel.headlines.isEmpty {
                    // Show message if list is empty after loading (and no error)
                    Text("No headlines available at the moment. Check back later!")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    // Show the list of headlines
                    List(viewModel.headlines) { headline in
                        // NavigationLink to a detail view (replace with your actual detail view)
                        NavigationLink(destination: HeadlineDetailView(headline: headline)) {
                             HeadlineRow(headline: headline)
                        }
                        // Optional: Add swipe actions if needed
                        // .swipeActions { Button("Save") { /* action */ } }
                    }
                    .listStyle(.plain) // Use plain list style
                    .refreshable { // Add pull-to-refresh
                        await viewModel.loadHeadlines()
                    }
                }
            }
            .navigationTitle("Newsum") // Set the title for the navigation bar
            .task {
                print("--- HeadlineListView Appeared ---")
                if viewModel.headlines.isEmpty {
                     print("Condition met, calling debounceLoadHeadlines")
                     await viewModel.debounceLoadHeadlines()
                } else {
                     print("Condition NOT met, headlines not empty")
                }
            }
        }
    }
}

// MARK: - Reusable Error View

struct ErrorView: View {
    let errorMessage: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.orange)
            Text("Error Loading Headlines")
                .font(.title2)
                .fontWeight(.semibold)
            Text(errorMessage)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
                .padding(.top)
        }
        .padding() // Add padding around the error content
    }
}


// MARK: - Preview

#Preview {
    HeadlineListView()
        // Example of how to inject a ViewModel with specific state for previews:
        // .environmentObject(HeadlineViewModel(headlines: [], isLoading: false, errorMessage: "Network Failed"))
}
