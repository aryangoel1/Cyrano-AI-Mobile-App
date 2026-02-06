import SwiftUI

@main
struct Cyrano_AI_Mobile_AppApp: App {
    @State private var conversationListVM = ConversationListViewModel()
    @State private var settingsVM = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(conversationListVM)
                .environment(settingsVM)
        }
    }
}
