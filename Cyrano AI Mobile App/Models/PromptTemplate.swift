import Foundation

struct PromptTemplate: Identifiable, Sendable {
    let id: String
    let label: String
    let icon: String
    let promptPrefix: String

    static let all: [PromptTemplate] = [
        PromptTemplate(
            id: "summarize", label: "Summarize",
            icon: "doc.text.magnifyingglass",
            promptPrefix: "Please summarize the following:\n\n"
        ),
        PromptTemplate(
            id: "rewrite", label: "Rewrite",
            icon: "arrow.triangle.2.circlepath",
            promptPrefix: "Please rewrite the following to be clearer and more concise:\n\n"
        ),
        PromptTemplate(
            id: "actions", label: "Action Items",
            icon: "checklist",
            promptPrefix: "Extract action items from the following:\n\n"
        ),
        PromptTemplate(
            id: "explain", label: "Explain",
            icon: "questionmark.circle",
            promptPrefix: "Please explain the following in simple terms:\n\n"
        ),
        PromptTemplate(
            id: "draft", label: "Draft Reply",
            icon: "arrowshape.turn.up.left",
            promptPrefix: "Draft a professional reply to the following:\n\n"
        ),
    ]
}
