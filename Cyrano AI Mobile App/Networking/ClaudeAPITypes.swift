import Foundation

// MARK: - Request

nonisolated struct ClaudeRequest: Encodable, Sendable {
    let model: String
    let maxTokens: Int
    let messages: [ClaudeMessageParam]
    let system: String?
    let stream: Bool

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case messages
        case system
        case stream
    }
}

nonisolated struct ClaudeMessageParam: Encodable, Sendable {
    let role: String
    let content: String
}

// MARK: - SSE Response Events

nonisolated struct SSEMessageStart: Decodable, Sendable {
    let type: String
    let message: SSEMessage
}

nonisolated struct SSEMessage: Decodable, Sendable {
    let id: String
    let role: String
    let model: String
    let usage: SSEUsage?
}

nonisolated struct SSEUsage: Decodable, Sendable {
    let inputTokens: Int?
    let outputTokens: Int?

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case outputTokens = "output_tokens"
    }
}

nonisolated struct SSEContentBlockDelta: Decodable, Sendable {
    let type: String
    let index: Int
    let delta: SSEDelta
}

nonisolated struct SSEDelta: Decodable, Sendable {
    let type: String
    let text: String?
}

nonisolated struct SSEMessageDelta: Decodable, Sendable {
    let type: String
    let delta: SSEMessageDeltaPayload
    let usage: SSEUsage?
}

nonisolated struct SSEMessageDeltaPayload: Decodable, Sendable {
    let stopReason: String?

    enum CodingKeys: String, CodingKey {
        case stopReason = "stop_reason"
    }
}

nonisolated struct SSEErrorEvent: Decodable, Sendable {
    let type: String
    let error: SSEErrorDetail
}

nonisolated struct SSEErrorDetail: Decodable, Sendable {
    let type: String
    let message: String
}
