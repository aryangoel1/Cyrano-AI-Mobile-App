import Foundation

nonisolated enum AppError: Error, LocalizedError, Sendable {
    case noAPIKey
    case invalidAPIKey
    case networkError(underlying: String)
    case rateLimited(retryAfterSeconds: Int?)
    case serverError(statusCode: Int, message: String)
    case overloaded
    case promptTooLong(current: Int, max: Int)
    case decodingError(detail: String)
    case streamCancelled
    case unknown(message: String)

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            "No API key configured. Go to Settings to add your Anthropic API key."
        case .invalidAPIKey:
            "Invalid API key. Please check your key in Settings."
        case .networkError(let msg):
            "Network error: \(msg)"
        case .rateLimited(let retry):
            "Rate limited. \(retry.map { "Retry in \($0)s" } ?? "Please wait.")"
        case .serverError(let code, let msg):
            "Server error (\(code)): \(msg)"
        case .overloaded:
            "Anthropic servers are overloaded. Please try again shortly."
        case .promptTooLong(let cur, let max):
            "Prompt is too long (\(cur) chars). Maximum is \(max)."
        case .decodingError(let d):
            "Response parsing error: \(d)"
        case .streamCancelled:
            "Generation was stopped."
        case .unknown(let msg):
            "An error occurred: \(msg)"
        }
    }
}
