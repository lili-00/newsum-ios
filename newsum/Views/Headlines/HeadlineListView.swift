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
                            await viewModel.loadHeadlines()
                        }
                    }
                }
            }
            .navigationTitle("Newsum")
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
        .padding()
    }
}

// MARK: - Preview
#Preview {
    HeadlineListView()
}
