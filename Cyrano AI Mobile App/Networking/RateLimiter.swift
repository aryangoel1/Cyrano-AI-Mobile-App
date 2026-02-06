import Foundation

nonisolated actor RateLimiter {
    private let maxRequests: Int
    private let windowSeconds: TimeInterval
    private var timestamps: [Date] = []

    init(maxRequests: Int = AppConstants.rateLimitMaxRequests,
         windowSeconds: TimeInterval = AppConstants.rateLimitWindowSeconds) {
        self.maxRequests = maxRequests
        self.windowSeconds = windowSeconds
    }

    func tryAcquire() -> Bool {
        let now = Date()
        timestamps.removeAll { now.timeIntervalSince($0) > windowSeconds }
        guard timestamps.count < maxRequests else { return false }
        timestamps.append(now)
        return true
    }
}
