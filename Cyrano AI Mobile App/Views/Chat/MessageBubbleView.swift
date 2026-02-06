import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 48) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .textSelection(.enabled)

                if let usage = message.usage {
                    Text("\(usage.inputTokens + usage.outputTokens) tokens · $\(usage.estimatedCost, specifier: "%.4f")")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .background(isUser ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))

            if !isUser { Spacer(minLength: 48) }
        }
    }
}
