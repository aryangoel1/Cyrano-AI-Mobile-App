import Foundation

// MARK: - Request

nonisolated struct ClaudeRequest: Encodable, Sendable {
    let model: String
    let maxTokens: Int
    let messages: [ClaudeMessageParam]
    let system: String?
    let stream: Bool

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(model, forKey: .model)
        try container.encode(maxTokens, forKey: .maxTokens)
        try container.encode(messages, forKey: .messages)
        try container.encode(stream, forKey: .stream)
        // Only include system if non-nil to avoid sending "system": null
        if let system {
            try container.encode(system, forKey: .system)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case model, maxTokens, messages, system, stream
    }
}

nonisolated struct ClaudeMessageParam: Encodable, Sendable {
    let role: String
    let content: String
}

// MARK: - SSE Response Events

nonisolated struct SSEEventBase: Decodable, Sendable {
    let type: String
}

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
}

nonisolated struct SSEErrorEvent: Decodable, Sendable {
    let type: String
    let error: SSEErrorDetail
}

nonisolated struct SSEErrorDetail: Decodable, Sendable {
    let type: String
    let message: String
}
