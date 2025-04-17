import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:8000/api/summary/latest"

    private init() {}

    func fetchLatestSummaries() async throws -> [NewsSummary] {
        guard let url = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Add any necessary headers here if needed in the future
        // request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }

            do {
                let decoder = JSONDecoder()
                let summaries = try decoder.decode([NewsSummary].self, from: data)
                return summaries
            } catch {
                throw NetworkError.decodingError(error)
            }
        } catch {
            // Handle cancellation gracefully if needed, otherwise treat as failure
             if (error as? URLError)?.code == .cancelled {
                 print("Request cancelled.")
                 // Optionally rethrow or return an empty array/specific state
             }
            throw NetworkError.requestFailed(error)
        }
    }
} 