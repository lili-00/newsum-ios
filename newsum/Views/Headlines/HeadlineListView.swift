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
    
    init() {
        print("+++ HeadlineListView INIT +++")
    }

    var body: some View {
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
                                // Title for the section
//                                HStack {
//                                    Text("Summaries")
//                                        .font(.title2)
//                                        .fontWeight(.bold)
//                                    
//                                    Spacer()
//                                }
//                                .padding(.horizontal, 16)
//                                .padding(.vertical, 8)
                                
                                // Headlines
                                ForEach(viewModel.headlines) { headline in
                                    ZStack {
                                        NavigationLink(destination: HeadlineDetailView(headline: headline), 
                                                      isActive: Binding(
                                                        get: { selectedHeadlineID == headline.id && !isAnimating },
                                                        set: { _ in }
                                                      )) {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                        
                                        HeadlineRow(headline: headline)
                                            .scaleEffect(selectedHeadlineID == headline.id && isAnimating ? 0.95 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedHeadlineID == headline.id && isAnimating)
                                            .onTapGesture {
                                                // Set selected ID and trigger animation
                                                selectedHeadlineID = headline.id
                                                isAnimating = true
                                                
                                                // Small delay before navigation to allow animation to complete
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                                    isAnimating = false
                                                }
                                            }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .refreshable {
                            do {
                                try await refreshHeadlines()
                            } catch is CancellationError {
                                // Silently handle cancellation errors - this is normal during scrolling
                                print("Refresh cancelled normally - not an error condition")
                                isRefreshing = false
                            } catch {
                                // Ensure we reset the refreshing state even on error
                                print("Refresh error: \(error)")
                                isRefreshing = false
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
            .navigationTitle("Newsum")
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
    
    // Improved refresh function with timeout and error handling
    private func refreshHeadlines() async throws {
        // Prevent multiple simultaneous refreshes
        guard !isRefreshing else { return }
        
        isRefreshing = true
        let previousHeadlineCount = viewModel.headlines.count
        
        // Create a task with a timeout
        do {
            try await withTimeout(seconds: 10) {
                await viewModel.loadHeadlines()
            }
            
            // If we get here, the refresh was successful
            if viewModel.errorMessage == nil && viewModel.headlines.count > 0 {
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
            }
            
            // Reset refreshing state on success
            isRefreshing = false
        } catch {
            // Handle timeout or other errors
            if let urlError = error as? URLError, urlError.code == .cancelled {
                // This is a normal cancellation during scroll - don't show error
                print("Request cancelled during refresh - this is normal behavior")
                // Don't set an error message for normal cancellations during scrolling
                viewModel.errorMessage = nil
            } else if error is CancellationError {
                // Handle cancellation errors (from task cancellation) - don't show as an error
                print("Task cancelled during refresh - this is normal behavior")
                // Clear any previous error message so it doesn't display
                viewModel.errorMessage = nil
            } else if error is TimeoutError {
                viewModel.errorMessage = "Request timed out. Please try again."
            } else {
                // For other errors, set the error message
                viewModel.errorMessage = error.localizedDescription
            }
            
            // Reset refreshing state on error
            isRefreshing = false
            
            // Re-throw to indicate failure to refreshable
            throw error 
        }
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
