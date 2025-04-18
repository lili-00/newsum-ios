import Foundation
import SwiftUI // Import SwiftUI for ObservableObject and MainActor

@MainActor // Ensure UI updates happen on the main thread
class NewsViewModel: ObservableObject {
    @Published var summaries: [NewsSummary] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let networkManager = NetworkManager.shared

    func fetchNews(isRefreshing: Bool = false) async {
        // Don't show loading indicator during background refresh
        if !isRefreshing {
             isLoading = true
        }
        // Clear error message only on initial load
        if !isRefreshing {
            errorMessage = nil
        }

        do {
            let fetchedSummaries = try await networkManager.fetchLatestSummaries()
            summaries = fetchedSummaries
            errorMessage = nil // Clear previous error on success
        } catch let error as NetworkError {
            errorMessage = mapErrorToMessage(error)
            // Optionally clear summaries or keep stale data on error
            // summaries = [] 
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            // summaries = []
        }

        isLoading = false
    }

    // Helper to provide user-friendly error messages
    private func mapErrorToMessage(_ error: NetworkError) -> String {
        switch error {
        case .invalidURL:
            return "Invalid API endpoint URL."
        case .requestFailed(let underlyingError):
            return "Failed to fetch news. Check your connection. Error: \(underlyingError.localizedDescription)"
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .decodingError(let underlyingError):
            return "Failed to process news data. Error: \(underlyingError.localizedDescription)"
        }
    }
} 