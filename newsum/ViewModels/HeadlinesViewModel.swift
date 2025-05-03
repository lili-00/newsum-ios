//
//  HeadlinesViewModel.swift
//  newsum
//
//  Created by Li Li on 4/20/25.
//

import Foundation
import Combine
import SwiftUI

@MainActor // Ensure UI updates happen on the main thread
class HeadlineViewModel: ObservableObject {
    @Published var headlines: [HeadlineSummary] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let networkManager = NetworkManager.shared
    private var debounceTask: Task<Void, Never>? = nil
    private let debounceInterval: TimeInterval = 0.5
    
    func debounceLoadHeadlines() async {
        // Cancel previous existing task
        debounceTask?.cancel()
        
        debounceTask = Task {
            do {
                let nanoseconds = UInt64(debounceInterval * 1_000_000_000)
                try await Task.sleep(nanoseconds: nanoseconds)
                
                guard !Task.isCancelled else { return }
                
                await loadHeadlines()
            } catch is CancellationError {
                print("Debounce task cancelled")
                
            } catch {
                // Handle other unexpected errors from Task.sleep or within the block
               print("Error during debounce task: \(error)")
               // Update the UI state to show the error
               // Ensure this UI update runs on the main actor (already guaranteed by @MainActor on the class)
               self.errorMessage = "Debounce mechanism failed: \(error.localizedDescription)"
               self.isLoading = false // Ensure loading indicator is turned off
            }
        }
    }
    
    func loadHeadlines() async {
        // Prevent starting a new load if one is already in progress
        guard !isLoading else {
            print("Already loading headlines. Ignoring duplicate request.") // Add for debugging
            return
        }
        
        isLoading = true
        errorMessage = nil

        do {
            let fetchedHeadlines = try await networkManager.fetchLatestHeadlines()
            // Only update headlines if we got data back
            if !fetchedHeadlines.isEmpty {
                headlines = fetchedHeadlines
            }
        } catch {
            // Handle specific cancellation errors - don't clear the headlines
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("Network request cancelled - preserving existing headlines")
            } else if error is CancellationError {
                print("Task cancelled - preserving existing headlines")
            } else {
                // Correctly use the extension method or helper function for other errors
                if let networkError = error as? NetworkError {
                    errorMessage = networkError.userFriendlyMessage // Using the extension method
                } else {
                    // Use the general helper for other errors
                    errorMessage = error.localizedDescription // Using the global helper function
                }
                // You might choose one consistent approach (e.g., always use mapErrorToMessage(error))
                print("Error loading headlines: \(errorMessage ?? "Unknown error")")
                
                // Only clear headlines for real errors, not cancellations
                if headlines.isEmpty {
                    print("No existing headlines to preserve")
                }
            }
        }

        isLoading = false
    }
}
