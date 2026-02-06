import SwiftUI

struct MessageInputView: View {
    @Bindable var viewModel: ChatViewModel

    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Message", text: $viewModel.inputText, axis: .vertical)
                .lineLimit(1...6)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    if viewModel.canSend {
                        viewModel.send()
                    }
                }

            Button {
                if viewModel.isStreaming {
                    viewModel.stop()
                } else {
                    viewModel.send()
                }
            } label: {
                Image(systemName: viewModel.isStreaming ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.title2)
            }
            .disabled(!viewModel.isStreaming && !viewModel.canSend)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
