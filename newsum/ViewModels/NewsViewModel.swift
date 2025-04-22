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
} 
