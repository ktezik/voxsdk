import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
            case .invalidURL:
                return "The URL is invalid."
            case .invalidResponse:
                return "The server responded with an invalid status code."
        }
    }
}
