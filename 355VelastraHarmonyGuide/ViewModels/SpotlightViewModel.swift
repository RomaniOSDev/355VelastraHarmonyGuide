import Combine
import Foundation

@MainActor
final class SpotlightViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var favouritesOnly = false

    func visibleItems(favouritedIDs: Set<String>) -> [SpotlightItem] {
        var items = SpotlightCatalog.all
        if favouritesOnly {
            items = items.filter { favouritedIDs.contains($0.id) }
        }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }
        return items.filter { item in
            item.title.localizedCaseInsensitiveContains(trimmed)
                || item.kicker.localizedCaseInsensitiveContains(trimmed)
                || item.body.localizedCaseInsensitiveContains(trimmed)
        }
    }

    func clearQuery() {
        query = ""
        favouritesOnly = false
    }
}
