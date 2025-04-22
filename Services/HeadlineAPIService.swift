import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case decodingError(Error)
    case invalidResponse
}

class HeadlineAPIService {
    private let baseURL = "http://localhost:8000/api/summary/headlines"

    func fetchHeadlines() async throws -> [HeadlineSummary] {
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw APIError.invalidResponse
            }

            let decoder = JSONDecoder()
            // Configure the decoder for ISO 8601 dates with fractional seconds
            decoder.dateDecodingStrategy = .custom { decoder -> Date in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: dateString) {
                    return date
                }
                // Fallback for dates without fractional seconds
                formatter.formatOptions = [.withInternetDateTime]
                 if let date = formatter.date(from: dateString) {
                    return date
                }
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
            
            do {
                 return try decoder.decode([HeadlineSummary].self, from: data)
            } catch {
                print("Decoding Error: \(error)") // Log the specific decoding error
                throw APIError.decodingError(error)
            }
           
        } catch {
             print("Request Failed: \(error)") // Log the specific request error
            throw APIError.requestFailed(error)
        }
    }
} 