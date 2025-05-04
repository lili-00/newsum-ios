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
    @State private var selectedHeadlineID: UUID? = nil
    @State private var isAnimating = false
    @State private var showRefreshToast = false
    @State private var isRefreshing = false
    @State private var currentDate = Date() // Current date that will be updated on refresh
    @State private var selectedHeadline: HeadlineSummary? = nil
    @State private var showHeadlineDetail = false
    
    init() {
        print("+++ HeadlineListView INIT +++")
    }

    var body: some View {
        ZStack {
            if showHeadlineDetail, let headline = selectedHeadline {
                // Detail view when a headline is selected
                HeadlineDetailView(headline: headline, onDismiss: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showHeadlineDetail = false
                        selectedHeadline = nil
                    }
                })
                .transition(.move(edge: .trailing))
                .zIndex(1)
            } else {
                // Main list view
                NavigationView {
                    ZStack {
                        // Background color
                        Color(.systemGroupedBackground)
                            .ignoresSafeArea()
                        
                        // Main content
                        VStack {
                            if viewModel.isLoading && viewModel.headlines.isEmpty {
                                // Show loading indicator only on initial load
                                ProgressView("Fetching headlines...")
                            } else if let errorMessage = viewModel.errorMessage {
                                // Show error message and retry button
                                ErrorView(errorMessage: errorMessage) {
                                    // Retry action
                                    Task {
                                        try? await refreshHeadlines()
                                    }
                                }
                            } else if viewModel.headlines.isEmpty {
                                // Show message if list is empty after loading (and no error)
                                VStack(spacing: 12) {
                                    Text("No headlines available at the moment. Check back later!")
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                    
                                    Button("Retry") {
                                        Task {
                                            try? await refreshHeadlines()
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            } else {
                                // Custom scroll view with headlines
                                ScrollView {
                                    VStack(spacing: 0) {
                                        // Your briefing section
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Summaries")
                                                .font(.largeTitle)
                                                .fontWeight(.bold)
                                                
                                            // Current date formatted like "Saturday, May 3"
                                            Text(currentDate.formatted(date: .complete, time: .omitted))
                                                .font(.headline)
                                                .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .padding(.bottom, 8)
                                        
                                        // Headlines
                                        ForEach(viewModel.headlines) { headline in
                                            HeadlineRow(headline: headline)
                                                .scaleEffect(selectedHeadlineID == headline.id && isAnimating ? 0.95 : 1.0)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedHeadlineID == headline.id && isAnimating)
                                                .onTapGesture {
                                                    // Set selected ID and trigger animation
                                                    selectedHeadlineID = headline.id
                                                    isAnimating = true
                                                    
                                                    // Set the selected headline and prepare to show detail
                                                    selectedHeadline = headline
                                                    
                                                    // Small delay before showing sheet to allow animation to complete
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                        isAnimating = false
                                                        withAnimation(.easeInOut) {
                                                            showHeadlineDetail = true
                                                        }
                                                    }
                                                }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                                .refreshable {
                                    print("Pull-to-refresh triggered")
                                    currentDate = Date()
                                    
                                    // Use a dedicated task to prevent cancellation issues
                                    let task = Task {
                                        await viewModel.loadHeadlines()
                                    }
                                    await task.value
                                    
                                    // Show toast on successful refresh
                                    if viewModel.headlines.count > 0 && viewModel.errorMessage == nil {
                                        withAnimation {
                                            showRefreshToast = true
                                        }
                                        
                                        // Auto-dismiss toast after 2 seconds
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                showRefreshToast = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Success toast notification
                        if showRefreshToast {
                            VStack {
                                Spacer()
                                Text("Headlines updated")
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.black.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                    .padding(.bottom, 40)
                            }
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut, value: showRefreshToast)
                            .zIndex(1)
                        }
                    }
//                    .navigationTitle("Newsum")
                    .task {
                        print("--- HeadlineListView Appeared ---")
                        if viewModel.headlines.isEmpty {
                            print("Condition met, calling refreshHeadlines")
                            try? await refreshHeadlines()
                        } else {
                            print("Condition NOT met, headlines not empty")
                        }
                    }
                }
            }
        }
    }
    
    // Improved refresh function with timeout and error handling
    private func refreshHeadlines() async throws {
        // Prevent multiple simultaneous refreshes
        guard !isRefreshing else { return }
        
        isRefreshing = true
        print("Starting headline refresh...")
        
        // Update current date to reflect latest refresh
        currentDate = Date()
        
        // Create a dedicated task to avoid cancellation from SwiftUI refresh
        let refreshTask = Task {
            await viewModel.loadHeadlines()
        }
        
        do {
            // Wait for the task to complete
            _ = await refreshTask.value
            
            // Show success toast if we have headlines
            if viewModel.errorMessage == nil && viewModel.headlines.count > 0 {
                print("Headlines refreshed successfully: \(viewModel.headlines.count) items")
                // Show success toast
                withAnimation {
                    showRefreshToast = true
                }
                
                // Auto-dismiss toast after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showRefreshToast = false
                    }
                }
            } else if let error = viewModel.errorMessage {
                print("Refresh completed with error: \(error)")
            } else {
                print("Refresh completed but no headlines found")
            }
        } catch {
            print("Error during refresh: \(error.localizedDescription)")
            // Error handling remains the same
        }
        
        isRefreshing = false
    }
    
    // Improved timeout function that properly handles cancellation
    private func withTimeout<T>(seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            let operationTask = group.addTaskUnlessCancelled {
                try await operation()
            }
            
            // Don't add timeout task if operation task wasn't added
            if operationTask {
                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                    throw TimeoutError()
                }
            }
            
            do {
                // Get the first completed task result
                if let result = try await group.next() {
                    // Cancel any remaining tasks
                    group.cancelAll()
                    return result
                } else {
                    throw CancellationError()
                }
            } catch {
                // Cancel everything on error
                group.cancelAll()
                throw error
            }
        }
    }
}

// Custom error for timeouts
struct TimeoutError: Error {}

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
        .padding()
    }
}

// MARK: - Preview
#Preview {
    HeadlineListView()
}
