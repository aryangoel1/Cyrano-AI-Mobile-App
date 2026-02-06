import Foundation

nonisolated enum StreamEvent: Sendable {
    case textDelta(String)
    case usage(inputTokens: Int, outputTokens: Int)
    case done(stopReason: String?)
    case error(AppError)
}

nonisolated protocol AIClient: Sendable {
    var providerName: String { get }

    func streamChat(
        messages: [(role: String, content: String)],
        systemPrompt: String?,
        maxTokens: Int
    ) -> AsyncThrowingStream<StreamEvent, Error>
}
