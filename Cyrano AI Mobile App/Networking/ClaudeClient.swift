import Foundation

nonisolated final class ClaudeClient: AIClient, Sendable {
    let providerName = "Claude"

    private let apiKey: String
    private let model: String
    private let session: URLSession
    private let baseURL: URL
    private let apiVersion: String

    init(apiKey: String, model: String = AppConstants.defaultModel) {
        self.apiKey = apiKey
        self.model = model
        self.session = URLSession.shared
        self.baseURL = URL(string: AppConstants.anthropicAPIBaseURL)!
        self.apiVersion = AppConstants.anthropicAPIVersion
    }

    func streamChat(
        messages: [(role: String, content: String)],
        systemPrompt: String?,
        maxTokens: Int
    ) -> AsyncThrowingStream<StreamEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var request = URLRequest(url: baseURL)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
                    request.setValue(apiVersion, forHTTPHeaderField: "anthropic-version")

                    let body = ClaudeRequest(
                        model: model,
                        maxTokens: maxTokens,
                        messages: messages.map { ClaudeMessageParam(role: $0.role, content: $0.content) },
                        system: systemPrompt,
                        stream: true
                    )
                    let encoder = JSONEncoder()
                    request.httpBody = try encoder.encode(body)

                    let (bytes, response) = try await session.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.yield(.error(.networkError(underlying: "Invalid response")))
                        continuation.finish()
                        return
                    }

                    guard httpResponse.statusCode == 200 else {
                        let appError: AppError
                        switch httpResponse.statusCode {
                        case 401:
                            appError = .invalidAPIKey
                        case 429:
                            let retry = httpResponse.value(forHTTPHeaderField: "Retry-After")
                                .flatMap(Int.init)
                            appError = .rateLimited(retryAfterSeconds: retry)
                        case 529:
                            appError = .overloaded
                        default:
                            appError = .serverError(
                                statusCode: httpResponse.statusCode,
                                message: "HTTP \(httpResponse.statusCode)"
                            )
                        }
                        continuation.yield(.error(appError))
                        continuation.finish()
                        return
                    }

                    let decoder = JSONDecoder()
                    for try await (event, data) in SSEParser.parse(bytes: bytes) {
                        try Task.checkCancellation()
                        guard let jsonData = data.data(using: .utf8) else { continue }

                        switch event {
                        case "content_block_delta":
                            if let delta = try? decoder.decode(SSEContentBlockDelta.self, from: jsonData),
                               delta.delta.type == "text_delta",
                               let text = delta.delta.text {
                                continuation.yield(.textDelta(text))
                            }
                        case "message_delta":
                            if let msgDelta = try? decoder.decode(SSEMessageDelta.self, from: jsonData),
                               let usage = msgDelta.usage {
                                continuation.yield(.usage(
                                    inputTokens: usage.inputTokens ?? 0,
                                    outputTokens: usage.outputTokens ?? 0
                                ))
                            }
                        case "message_stop":
                            continuation.yield(.done(stopReason: nil))
                        case "error":
                            if let err = try? decoder.decode(SSEErrorEvent.self, from: jsonData) {
                                if err.error.type == "overloaded_error" {
                                    continuation.yield(.error(.overloaded))
                                } else if err.error.type == "rate_limit_error" {
                                    continuation.yield(.error(.rateLimited(retryAfterSeconds: nil)))
                                } else {
                                    continuation.yield(.error(.serverError(
                                        statusCode: 0, message: err.error.message
                                    )))
                                }
                            }
                        default:
                            break
                        }
                    }
                    continuation.finish()
                } catch is CancellationError {
                    continuation.yield(.error(.streamCancelled))
                    continuation.finish()
                } catch {
                    continuation.yield(.error(.networkError(underlying: error.localizedDescription)))
                    continuation.finish()
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
