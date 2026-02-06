import SwiftUI

struct ConversationListView: View {
    @Environment(ConversationListViewModel.self) private var conversationListVM
    @Environment(\.dismiss) private var dismiss
    let onSelect: (UUID) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(conversationListVM.conversations) { conversation in
                    Button {
                        onSelect(conversation.id)
                        dismiss()
                    } label: {
                        ConversationRowView(conversation: conversation)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        conversationListVM.deleteConversation(
                            id: conversationListVM.conversations[index].id
                        )
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        conversationListVM.createConversation()
                        dismiss()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .overlay {
                if conversationListVM.conversations.isEmpty {
                    ContentUnavailableView("No Conversations",
                                           systemImage: "bubble.left.and.bubble.right",
                                           description: Text("Start a new chat to begin."))
                }
            }
        }
    }
}
