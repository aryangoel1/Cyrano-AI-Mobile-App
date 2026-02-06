import Foundation
import Observation

@Observable
final class ChatViewModel {

    // MARK: - State Machine

    enum ChatState: Equatable {
        case idle
        case sending
        case streaming
        case done
        case error(String)
    }

    // MARK: - Published State

    private(set) var state: ChatState = .idle
    var conversation: Conversation
    var inputText: String = ""

    // MARK: - Configuration

    var isMultiTurn: Bool {
        get { conversation.isMultiTurn }
        set { conversation.isMultiTurn = newValue }
    }

    // MARK: - Dependencies

    private var client: (any AIClient)?
    private var currentTask: Task<Void, Never>?
    private let rateLimiter = RateLimiter()
    private var maxPromptLength: Int
    private var maxOutputTokens: Int

    // MARK: - Computed

    var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && state != .sending && state != .streaming
            && client != nil
    }

    var isStreaming: Bool { state == .streaming || state == .sending }

    var canRetry: Bool {
        if case .error = state { return true }
        if case .done = state { return conversation.messages.last?.role == .assistant }
        return false
    }

    // MARK: - Init

    init(conversation: Conversation,
         maxPromptLength: Int = AppConstants.defaultMaxPromptLength,
         maxOutputTokens: Int = AppConstants.defaultMaxOutputTokens) {
        self.conversation = conversation
        self.maxPromptLength = maxPromptLength
        self.maxOutputTokens = maxOutputTokens
    }

    func updateClient(_ client: (any AIClient)?) {
        self.client = client
    }

    func updateSettings(maxPromptLength: Int, maxOutputTokens: Int) {
        self.maxPromptLength = maxPromptLength
        self.maxOutputTokens = maxOutputTokens
    }

    // MARK: - Actions

    func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let client else { return }

        if trimmed.count > maxPromptLength {
            state = .error(AppError.promptTooLong(current: trimmed.count, max: maxPromptLength).localizedDescription)
            return
        }

        let userMessage = ChatMessage(role: .user, content: trimmed)
        conversation.messages.append(userMessage)
        conversation.updatedAt = Date()

        if conversation.title == "New Chat" {
            conversation.title = String(trimmed.prefix(40))
        }

        inputText = ""
        state = .sending

        let messagesToSend: [(role: String, content: String)]
        if conversation.isMultiTurn {
            messagesToSend = conversation.messages
                .filter { $0.role != .system }
                .map { (role: $0.role.rawValue, content: $0.content) }
        } else {
            messagesToSend = [(role: "user", content: trimmed)]
        }

        let assistantMessageID = UUID()
        conversation.messages.append(
            ChatMessage(id: assistantMessageID, role: .assistant, content: "", isStreaming: true)
        )

        let maxTokens = maxOutputTokens
        let limiter = rateLimiter

        currentTask = Task {
            let allowed = await limiter.tryAcquire()
            guard allowed else {
                state = .error(AppError.rateLimited(retryAfterSeconds: nil).localizedDescription)
                removeMessage(id: assistantMessageID)
                return
            }

            let stream = client.streamChat(
                messages: messagesToSend,
                systemPrompt: nil,
                maxTokens: maxTokens
            )

            var receivedText = false
            var finalUsage: ClaudeUsage?

            do {
                for try await event in stream {
                    switch event {
                    case .textDelta(let text):
                        if !receivedText {
                            receivedText = true
                            state = .streaming
                        }
                        appendToMessage(id: assistantMessageID, text: text)

                    case .usage(let input, let output):
                        finalUsage = ClaudeUsage(inputTokens: input, outputTokens: output)

                    case .done:
                        finalizeMessage(id: assistantMessageID, usage: finalUsage)
                        state = .done
                        return

                    case .error(let appError):
                        if case .streamCancelled = appError {
                            finalizeMessage(id: assistantMessageID, usage: finalUsage)
                            state = .done
                        } else {
                            state = .error(appError.localizedDescription)
                        }
                        return
                    }
                }
            } catch {
                finalizeMessage(id: assistantMessageID, usage: finalUsage)
                state = .error(error.localizedDescription)
                return
            }

            if state == .streaming || state == .sending {
                finalizeMessage(id: assistantMessageID, usage: finalUsage)
                state = .done
            }
        }
    }

    func stop() {
        currentTask?.cancel()
        currentTask = nil
        if state == .sending || state == .streaming {
            state = .done
        }
    }

    func retry() {
        guard canRetry else { return }
        if let last = conversation.messages.last, last.role == .assistant {
            conversation.messages.removeLast()
        }
        if let lastUser = conversation.messages.last, lastUser.role == .user {
            inputText = lastUser.content
            conversation.messages.removeLast()
        }
        state = .idle
        send()
    }

    func applyTemplate(_ template: PromptTemplate) {
        if inputText.isEmpty {
            inputText = template.promptPrefix
        } else {
            inputText = template.promptPrefix + inputText
        }
    }

    func exportText() -> String {
        conversation.messages.map { msg in
            let role = msg.role == .user ? "You" : "Assistant"
            return "[\(role)]\n\(msg.content)"
        }.joined(separator: "\n\n")
    }

    func clearError() {
        if case .error = state {
            state = .idle
        }
    }

    // MARK: - Private Helpers

    private func appendToMessage(id: UUID, text: String) {
        guard let index = conversation.messages.firstIndex(where: { $0.id == id }) else { return }
        conversation.messages[index].content += text
    }

    private func finalizeMessage(id: UUID, usage: ClaudeUsage?) {
        guard let index = conversation.messages.firstIndex(where: { $0.id == id }) else { return }
        conversation.messages[index].isStreaming = false
        conversation.messages[index].usage = usage
        conversation.updatedAt = Date()
    }

    private func removeMessage(id: UUID) {
        conversation.messages.removeAll { $0.id == id }
    }
}
