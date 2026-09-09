import Foundation

struct TimelineEntry: Identifiable, Equatable {
    enum Kind: Equatable {
        case memo(EventMemo)
        case narrative(EventNarrative)
        case spotlight(SpotlightItem)
    }

    let id: String
    let date: Date
    let kind: Kind

    var isPinned: Bool {
        if case .memo(let memo) = kind {
            return memo.isPinned
        }
        return false
    }
}
