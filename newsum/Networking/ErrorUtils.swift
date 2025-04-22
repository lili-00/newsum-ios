//
//  ErrorUtils.swift
//  newsum
//
//  Created by Li Li on 4/20/25.
//

import Foundation

// Definition of NetworkError (remains the same)
enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error) // Holds the underlying error
    case invalidResponse
    case decodingError(Error) // Holds the underlying error
    // case requestCancelled // Optional: Could add this if preferred over checking URLError code
}

// Extension for NetworkError's specific messages (remains the same)
extension NetworkError {
    /// Provides a user-friendly message for NetworkError types.
    var userFriendlyMessage: String {
        switch self {
        case .invalidURL:
            return "Internal error: Invalid API endpoint URL."
        case .requestFailed(let underlyingError):
            print("Network request failed with underlying error: \(underlyingError)")
            // We let the global mapErrorToMessage handle underlying URLErrors now
            return mapErrorToMessage(underlyingError) // Delegate to global mapper
        case .invalidResponse:
            return "Received an invalid response from the server. Please try again later."
        case .decodingError(let underlyingError):
            print("Detailed Decoding Error: \(underlyingError)")
            if let decodingErr = underlyingError as? DecodingError {
                 print("Decoding Error Details: \(decodingErr)")
            }
            return "Failed to process data from the server."
        // case .requestCancelled: // If you added this case
        //     return "Request was cancelled."
        }
    }
}


// MARK: - Global Error Mapping Function (Moved Here)

/// Maps various error types to a user-friendly message string.
func mapErrorToMessage(_ error: Error) -> String {
    // Check for our custom NetworkError first
    if let networkError = error as? NetworkError {
        // Use the specific message defined in the extension
        // (Handle .requestFailed by looking at its underlying error below)
        if case .requestFailed(let underlying) = networkError {
             // If it's requestFailed, map the *underlying* error instead
             return mapErrorToMessage(underlying)
        } else {
             return networkError.userFriendlyMessage
        }
    }

    // Check for URLSession errors (URLError)
    let nsError = error as NSError
    if nsError.domain == NSURLErrorDomain {
        switch nsError.code {
        case NSURLErrorNotConnectedToInternet:
            return "No internet connection. Please check your connection and try again."
        case NSURLErrorTimedOut:
            return "The request timed out. Please try again."
        case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
            return "Could not reach the server. Please try again later."
         case NSURLErrorCancelled:
             return "Request cancelled." // Specific message for cancellation
        // Add other relevant NSURLError codes if needed
        default:
            // Fallback for other URL errors
            return "A network error occurred: \(error.localizedDescription)"
        }
    }

    // Fallback for any other unexpected error types
    return "An unexpected error occurred: \(error.localizedDescription)"
}
