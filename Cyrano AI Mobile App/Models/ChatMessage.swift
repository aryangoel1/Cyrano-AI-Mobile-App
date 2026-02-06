import Foundation

enum MessageRole: String, Sendable {
    case user
    case assistant
    case system
}

struct ClaudeUsage: Sendable {
    let inputTokens: Int
    let outputTokens: Int

    var estimatedCost: Double {
        (Double(inputTokens) * 3.0 / 1_000_000) + (Double(outputTokens) * 15.0 / 1_000_000)
    }
}

struct ChatMessage: Identifiable, Sendable {
    let id: UUID
    let role: MessageRole
    var content: String
    let timestamp: Date
    var isStreaming: Bool
    var usage: ClaudeUsage?

    init(
        id: UUID = UUID(),
        role: MessageRole,
        content: String,
        timestamp: Date = Date(),
        isStreaming: Bool = false,
        usage: ClaudeUsage? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.isStreaming = isStreaming
        self.usage = usage
    }
}
