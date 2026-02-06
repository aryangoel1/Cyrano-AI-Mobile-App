import Foundation

nonisolated struct SSEParser: Sendable {

    static func parse(
        bytes: URLSession.AsyncBytes
    ) -> AsyncThrowingStream<(event: String, data: String), Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var currentEvent = ""
                    var currentData = ""

                    for try await line in bytes.lines {
                        if line.hasPrefix("event: ") {
                            currentEvent = String(line.dropFirst(7))
                        } else if line.hasPrefix("data: ") {
                            let chunk = String(line.dropFirst(6))
                            if currentData.isEmpty {
                                currentData = chunk
                            } else {
                                currentData += "\n" + chunk
                            }
                        } else if line.isEmpty {
                            if !currentEvent.isEmpty && !currentData.isEmpty {
                                continuation.yield((event: currentEvent, data: currentData))
                            }
                            currentEvent = ""
                            currentData = ""
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
}
