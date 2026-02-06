import SwiftUI

struct ErrorBannerView: View {
    let message: String
    let onDismiss: () -> Void
    let onRetry: (() -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
            Text(message)
                .font(.caption)
                .lineLimit(3)
            Spacer()
            if let onRetry {
                Button("Retry", action: onRetry)
                    .font(.caption.bold())
            }
            Button { onDismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }
}
