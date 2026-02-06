import Foundation
import Observation

@Observable
final class ConversationListViewModel {
    private(set) var conversations: [Conversation] = []
    var selectedConversationID: UUID?

    private let maxConversations = AppConstants.maxConversations

    var selectedConversation: Conversation? {
        conversations.first { $0.id == selectedConversationID }
    }

    @discardableResult
    func createConversation(multiTurn: Bool = true) -> Conversation {
        let conversation = Conversation(isMultiTurn: multiTurn)
        conversations.insert(conversation, at: 0)
        selectedConversationID = conversation.id
        enforceLimit()
        return conversation
    }

    func deleteConversation(id: UUID) {
        conversations.removeAll { $0.id == id }
        if selectedConversationID == id {
            selectedConversationID = conversations.first?.id
        }
    }

    func updateConversation(_ conversation: Conversation) {
        guard let index = conversations.firstIndex(where: { $0.id == conversation.id }) else { return }
        conversations[index] = conversation
    }

    private func enforceLimit() {
        if conversations.count > maxConversations {
            conversations = Array(conversations.prefix(maxConversations))
        }
    }
}
