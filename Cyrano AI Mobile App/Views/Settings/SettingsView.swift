import SwiftUI

struct SettingsView: View {
    @Environment(SettingsViewModel.self) private var settingsVM
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = settingsVM

        NavigationStack {
            Form {
                Section("API Key") {
                    SecureField("Anthropic API Key", text: $settings.apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    Button("Save Key") {
                        settingsVM.saveAPIKey()
                    }
                    .disabled(settings.apiKey.isEmpty)

                    if settingsVM.isKeyValid {
                        Label("Key saved and valid", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }

                Section("Model") {
                    Picker("Model", selection: $settings.selectedModel) {
                        ForEach(settingsVM.availableModels, id: \.id) { model in
                            Text(model.label).tag(model.id)
                        }
                    }
                }

                Section("Cost Controls") {
                    Stepper("Max output tokens: \(settingsVM.maxOutputTokens)",
                            value: $settings.maxOutputTokens, in: 256...8192, step: 256)
                    Stepper("Max prompt length: \(settingsVM.maxPromptLength)",
                            value: $settings.maxPromptLength, in: 1000...50000, step: 1000)
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0")
                    Button("Clear API Key", role: .destructive) {
                        settingsVM.clearAPIKey()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
