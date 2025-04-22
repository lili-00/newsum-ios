import Foundation

// MARK: - Network Error Definition (Keep this definition accessible)
class NetworkManager {
    static let shared = NetworkManager()

    // Base URL for the API
    private let baseURL = "http://34.21.101.88:8080/api"

    // JSON Decoder configured for date parsing
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .iso8601

        // decoder.keyDecodingStrategy = .convertFromSnakeCase // Uncomment if needed

        return decoder
    }()

    // Private initializer enforces singleton pattern
    private init() {}

    // --- Fetch Latest Headlines ---
    func fetchLatestHeadlines() async throws -> [HeadlineSummary] {
        guard let url = URL(string: baseURL + "/summary/headlines") else {
            throw NetworkError.invalidURL
        }
        print("Fetching Headlines from: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let data: Data
        let response: URLResponse

        // Step 1: Perform Network Request
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("Request cancelled in NetworkManager (Headlines).")
                throw error
            } else {
                print("Network transport failed in NetworkManager (Headlines): \(error)")
                throw NetworkError.requestFailed(error)
            }
        }

        // Step 2: Validate Response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        print("Headlines Response Status Code: \(httpResponse.statusCode)")
        guard httpResponse.statusCode == 200 else {
             if let bodyString = String(data: data, encoding: .utf8) {
                 print("Error Response Body (Headlines): \(bodyString)")
             }
            throw NetworkError.invalidResponse // Or a more specific error
        }

        // Step 3: Decode Data
        do {
            // Use the configured decoder instance (now using .iso8601)
            let headlines = try decoder.decode([HeadlineSummary].self, from: data)
            print("Successfully decoded \(headlines.count) headlines.")
            return headlines
        } catch let decodingError {
            print("Failed to decode Headlines: \(decodingError)")
            if let swiftDecodingError = decodingError as? DecodingError {
                 print("Detailed Decoding Error: \(swiftDecodingError)")
            }
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON String (Headlines) that failed decoding: \(jsonString)")
            }
            throw NetworkError.decodingError(decodingError)
        }
    }

    // --- Fetch Latest Summaries ---
    func fetchLatestSummaries() async throws -> [NewsSummary] {
        guard let url = URL(string: baseURL + "/summary/latest") else {
            throw NetworkError.invalidURL
        }

        print("Fetching Summaries from: \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // request.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                 throw NetworkError.invalidResponse
             }

            print("Summaries Response Status Code: \(httpResponse.statusCode)")

            guard httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }

            do {
                 // Use the configured decoder instance
                let summaries = try decoder.decode([NewsSummary].self, from: data)
                 print("Successfully decoded \(summaries.count) summaries.")
                return summaries
            } catch let decodingError {
                print("Failed to decode Summaries: \(decodingError)")
                 if let jsonString = String(data: data, encoding: .utf8) {
                     print("Raw JSON String (Summaries): \(jsonString)")
                 }
                throw NetworkError.decodingError(decodingError)
            }

        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("Request cancelled in NetworkManager (Summaries).")
                throw error // Rethrow original cancellation
            } else {
                print("Network request failed in NetworkManager (Summaries): \(error)")
                throw NetworkError.requestFailed(error) // Wrap other errors
            }
        }
    }
}
