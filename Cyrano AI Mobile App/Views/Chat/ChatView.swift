import SwiftUI

struct ChatView: View {
    @Bindable var viewModel: ChatViewModel
    @Environment(ConversationListViewModel.self) private var conversationListVM
    @Environment(SettingsViewModel.self) private var settingsVM

    @State private var showHistory = false
    @State private var showSettings = false
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Multi-turn toggle
                Picker("Mode", selection: $viewModel.isMultiTurn) {
                    Text("Single Turn").tag(false)
                    Text("Multi Turn").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 4)

                Divider()

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.conversation.messages) { message in
                                MessageBubbleView(message: message)
                                    .id(message.id)
                            }

                            if viewModel.state == .sending {
                                StreamingIndicatorView()
                                    .id("streaming-indicator")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.conversation.messages.count) {
                        if let last = viewModel.conversation.messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.conversation.messages.last?.content) {
                        if let last = viewModel.conversation.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                // API key warning
                if !settingsVM.isKeyValid {
                    ErrorBannerView(
                        message: "No valid API key. Tap Settings (gear icon) to add your Anthropic key.",
                        onDismiss: { },
                        onRetry: nil
                    )
                }

                // Error banner
                if case .error(let msg) = viewModel.state {
                    ErrorBannerView(
                        message: msg,
                        onDismiss: { viewModel.clearError() },
                        onRetry: viewModel.canRetry ? { viewModel.retry() } : nil
                    )
                }

                Divider()

                // Template bar + input
                PromptTemplateBar { template in
                    viewModel.applyTemplate(template)
                }
                .padding(.vertical, 4)

                MessageInputView(viewModel: viewModel)
            }
            .navigationTitle("Cyrano AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if viewModel.canRetry {
                        Button {
                            viewModel.retry()
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                    }
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(viewModel.conversation.messages.isEmpty)

                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showHistory) {
                ConversationListView { selectedID in
                    conversationListVM.selectedConversationID = selectedID
                }
            }
            .sheet(isPresented: $showSettings, onDismiss: {
                viewModel.updateClient(settingsVM.makeClient())
                viewModel.updateSettings(
                    maxPromptLength: settingsVM.maxPromptLength,
                    maxOutputTokens: settingsVM.maxOutputTokens
                )
            }) {
                SettingsView()
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheetView(items: [viewModel.exportText()])
            }
            .onAppear {
                viewModel.updateClient(settingsVM.makeClient())
            }
            .onChange(of: settingsVM.apiKey) {
                viewModel.updateClient(settingsVM.makeClient())
            }
            .onChange(of: settingsVM.selectedModel) {
                viewModel.updateClient(settingsVM.makeClient())
            }
            .onChange(of: settingsVM.maxOutputTokens) {
                viewModel.updateSettings(
                    maxPromptLength: settingsVM.maxPromptLength,
                    maxOutputTokens: settingsVM.maxOutputTokens
                )
            }
            .onChange(of: settingsVM.maxPromptLength) {
                viewModel.updateSettings(
                    maxPromptLength: settingsVM.maxPromptLength,
                    maxOutputTokens: settingsVM.maxOutputTokens
                )
            }
        }
    }
}
