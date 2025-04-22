import SwiftUI

@MainActor // Ensure UI updates happen on the main thread
class HeadlineViewModel: ObservableObject {
    @Published var headlines: [HeadlineSummary] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let apiService = HeadlineAPIService()

    func loadHeadlines() async {
        isLoading = true
        errorMessage = nil
        
        do {
            headlines = try await apiService.fetchHeadlines()
        } catch {
            // Handle different types of errors
            if let apiError = error as? APIError {
                switch apiError {
                case .invalidURL:
                    errorMessage = "Invalid API endpoint URL."
                case .requestFailed(let underlyingError):
                    errorMessage = "Network request failed: \(underlyingError.localizedDescription)"
                case .decodingError(let underlyingError):
                    errorMessage = "Failed to decode data: \(underlyingError.localizedDescription)"
                     // Log detailed decoding error for debugging
                    if let decodingErr = underlyingError as? DecodingError {
                        print("Detailed Decoding Error: \(decodingErr)")
                    }
                case .invalidResponse:
                    errorMessage = "Received an invalid response from the server."
                }
            } else {
                errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            }
            print("Error loading headlines: \(errorMessage ?? "Unknown error")") // Print error to console
        }
        
        isLoading = false
    }
} 