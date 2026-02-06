import Foundation

struct Conversation: Identifiable, Sendable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    let createdAt: Date
    var updatedAt: Date
    var isMultiTurn: Bool

    var lastMessage: ChatMessage? { messages.last }

    var previewText: String {
        guard let first = messages.first(where: { $0.role == .user }) else { return "New conversation" }
        let text = first.content
        return text.count > 80 ? String(text.prefix(80)) + "…" : text
    }

    init(
        id: UUID = UUID(),
        title: String = "New Chat",
        messages: [ChatMessage] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isMultiTurn: Bool = true
    ) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isMultiTurn = isMultiTurn
    }
}
