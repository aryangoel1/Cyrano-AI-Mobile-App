import SwiftUI

struct ConversationRowView: View {
    let conversation: Conversation

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(conversation.title)
                .font(.headline)
                .lineLimit(1)

            Text(conversation.previewText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Text(conversation.updatedAt, style: .relative)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
