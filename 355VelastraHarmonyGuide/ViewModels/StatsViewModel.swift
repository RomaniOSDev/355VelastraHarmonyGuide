import Combine
import Foundation

struct ActivityDay: Identifiable {
    var id: Date { day }
    let day: Date
    let memos: Int
    let captions: Int
}

struct MixSlice: Identifiable {
    var id: String { title }
    let title: String
    let count: Int
}

struct TagSlice: Identifiable {
    var id: String { tag }
    let tag: String
    let count: Int
}

@MainActor
final class StatsViewModel: ObservableObject {
    func activity(from store: DataStore, days: Int = 14) -> [ActivityDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<days).reversed().compactMap { offset -> ActivityDay? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let next = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            let memos = store.memos.filter { $0.createdAt >= day && $0.createdAt < next }.count
            let captions = store.narratives.filter { $0.createdAt >= day && $0.createdAt < next }.count
            return ActivityDay(day: day, memos: memos, captions: captions)
        }
    }

    func mix(from store: DataStore) -> [MixSlice] {
        [
            MixSlice(title: "Memos", count: store.memos.count),
            MixSlice(title: "Captions", count: store.narratives.count),
            MixSlice(title: "Hearts", count: store.favouritedCollections.count)
        ]
    }

    func topTags(from store: DataStore) -> [TagSlice] {
        var counts: [String: Int] = [:]
        let pooled = store.memos.flatMap(\.tags) + store.narratives.flatMap(\.tags)
        for tag in pooled {
            let key = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty else { continue }
            counts[key, default: 0] += 1
        }
        return counts
            .map { TagSlice(tag: $0.key, count: $0.value) }
            .sorted { lhs, rhs in
                if lhs.count == rhs.count {
                    return lhs.tag.localizedCaseInsensitiveCompare(rhs.tag) == .orderedAscending
                }
                return lhs.count > rhs.count
            }
            .prefix(6)
            .map { $0 }
    }

    func countdownLine(eventDate: Date?) -> String? {
        guard let eventDate else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: eventDate)
        let days = calendar.dateComponents([.day], from: start, to: target).day ?? 0
        if days > 1 {
            return "\(days) days until the day"
        }
        if days == 1 {
            return "1 day until the day"
        }
        if days == 0 {
            return "The day is today"
        }
        let past = abs(days)
        return past == 1 ? "1 day since the day" : "\(past) days since the day"
    }
}
