import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var apiKey: String = ""
    var selectedModel: String = AppConstants.defaultModel
    var maxOutputTokens: Int = AppConstants.defaultMaxOutputTokens
    var maxPromptLength: Int = AppConstants.defaultMaxPromptLength

    private(set) var isKeyValid: Bool = false

    var availableModels: [(label: String, id: String)] {
        [
            ("Claude Sonnet 4.5", "claude-sonnet-4-5-20250929"),
            ("Claude Haiku 3.5", "claude-haiku-3-5-20241022"),
        ]
    }

    init() {
        loadFromKeychain()
    }

    func saveAPIKey() {
        KeychainHelper.save(key: "anthropic_api_key", value: apiKey)
        validate()
    }

    func loadFromKeychain() {
        apiKey = KeychainHelper.load(key: "anthropic_api_key") ?? ""
        validate()
    }

    func clearAPIKey() {
        KeychainHelper.delete(key: "anthropic_api_key")
        apiKey = ""
        isKeyValid = false
    }

    func makeClient() -> (any AIClient)? {
        guard isKeyValid else { return nil }
        return ClaudeClient(apiKey: apiKey, model: selectedModel)
    }

    private func validate() {
        isKeyValid = apiKey.hasPrefix("sk-ant-") && apiKey.count > 20
    }
}
