import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed
    case invalidResponse
    case networkError(String)
    case serverError(String)
    case unauthorized
    case noData
    case cancelled
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        case .decodingFailed:
            return "Failed to decode response"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unauthorized:
            return "Unauthorized request"
        case .noData:
            return "No data received"
        case .cancelled:
            return "Request was cancelled"
        case .unknown:
            return "Unknown error occurred"
        }
    }
} 