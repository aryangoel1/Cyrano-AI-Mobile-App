import Foundation

nonisolated enum AppConstants {
    static let maxConversations = 10
    static let defaultMaxOutputTokens = 4096
    static let defaultMaxPromptLength = 12_000
    static let defaultModel = "claude-sonnet-4-5-20250929"
    static let rateLimitMaxRequests = 10
    static let rateLimitWindowSeconds: TimeInterval = 60
    static let anthropicAPIBaseURL = "https://api.anthropic.com/v1/messages"
    static let anthropicAPIVersion = "2023-06-01"
    static let keychainServiceName = "com.cyrano-ai.mobile-app"
}
