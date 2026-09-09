import Combine
import Foundation

@MainActor
final class TimelineViewModel: ObservableObject {
    func entries(from store: DataStore) -> [TimelineEntry] {
        var items: [TimelineEntry] = []

        for memo in store.memos {
            items.append(
                TimelineEntry(
                    id: "memo-\(memo.id.uuidString)",
                    date: memo.chronicleAt,
                    kind: .memo(memo)
                )
            )
        }

        for narrative in store.narratives {
            items.append(
                TimelineEntry(
                    id: "nar-\(narrative.id.uuidString)",
                    date: narrative.dateStamp,
                    kind: .narrative(narrative)
                )
            )
        }

        for mark in store.favouritedCollections {
            if let item = SpotlightCatalog.item(id: mark.id) {
                items.append(
                    TimelineEntry(
                        id: "spot-\(mark.id)",
                        date: mark.markedAt,
                        kind: .spotlight(item)
                    )
                )
            }
        }

        return items.sorted { lhs, rhs in
            let pinL = lhs.isPinned
            let pinR = rhs.isPinned
            if pinL != pinR {
                return pinL && !pinR
            }
            return lhs.date > rhs.date
        }
    }
}
