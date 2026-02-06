import SwiftUI

struct ContentView: View {
    @Environment(ConversationListViewModel.self) private var conversationListVM
    @Environment(SettingsViewModel.self) private var settingsVM

    @State private var chatViewModel: ChatViewModel?

    var body: some View {
        Group {
            if let chatViewModel {
                ChatView(viewModel: chatViewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            ensureConversation()
        }
        .onChange(of: conversationListVM.selectedConversationID) {
            loadSelectedConversation()
        }
    }

    private func ensureConversation() {
        if conversationListVM.conversations.isEmpty {
            conversationListVM.createConversation()
        }
        if conversationListVM.selectedConversationID == nil {
            conversationListVM.selectedConversationID = conversationListVM.conversations.first?.id
        }
        loadSelectedConversation()
    }

    private func loadSelectedConversation() {
        guard let selected = conversationListVM.selectedConversation else { return }

        if chatViewModel?.conversation.id != selected.id {
            let vm = ChatViewModel(
                conversation: selected,
                maxPromptLength: settingsVM.maxPromptLength,
                maxOutputTokens: settingsVM.maxOutputTokens
            )
            vm.updateClient(settingsVM.makeClient())
            chatViewModel = vm
        }
    }
}

#Preview {
    ContentView()
        .environment(ConversationListViewModel())
        .environment(SettingsViewModel())
}
