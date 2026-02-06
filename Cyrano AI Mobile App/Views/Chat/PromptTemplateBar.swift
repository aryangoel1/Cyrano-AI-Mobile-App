import SwiftUI

struct PromptTemplateBar: View {
    let onSelect: (PromptTemplate) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PromptTemplate.all) { template in
                    Button {
                        onSelect(template)
                    } label: {
                        Label(template.label, systemImage: template.icon)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.quaternary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}
