import Combine
import Foundation

@MainActor
final class DataStore: ObservableObject {
    @Published var memos: [EventMemo] = []
    @Published var narratives: [EventNarrative] = []
    @Published var favouritedCollections: [FavouritedMark] = []
    @Published var recentlyUsedTags: [String] = []
    @Published var preferredEmoji: String = "✦"
    @Published var lastActivityDate: Date?
    @Published var eventDate: Date?
    @Published var checklist: [ChecklistItem] = []
    @Published var vendors: [VendorCard] = []
    @Published var envelopes: [BudgetEnvelope] = []
    @Published var showBeats: [ShowBeat] = []
    @Published var guests: [GuestNote] = []
    @Published var swatches: [MoodSwatch] = []

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let memos = "memos"
        static let captions = "captions"
        static let favouritedCollections = "favouritedCollections"
        static let recentlyUsedTags = "recentlyUsedTags"
        static let preferredEmoji = "preferredEmoji"
        static let lastActivityDate = "lastActivityDate"
        static let eventDate = "eventDate"
        static let checklist = "checklist"
        static let vendors = "vendors"
        static let envelopes = "envelopes"
        static let showBeats = "showBeats"
        static let guests = "guests"
        static let swatches = "swatches"
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    init() {
        loadAll()
    }

    func upsertMemo(_ memo: EventMemo) {
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            memos[index] = memo
        } else {
            memos.insert(memo, at: 0)
        }
        preferredEmoji = memo.emoji
        rememberTags(memo.tags)
        touchActivity()
        persist(memos, key: Keys.memos)
        persist(preferredEmoji, key: Keys.preferredEmoji)
        ReminderScheduler.sync(memo: memo)
    }

    func deleteMemo(_ memo: EventMemo) {
        memos.removeAll { $0.id == memo.id }
        ReminderScheduler.cancel(id: memo.id)
        touchActivity()
        persist(memos, key: Keys.memos)
    }

    func sendMemoToTimeline(_ memo: EventMemo) {
        var updated = memo
        updated.chronicleAt = Date()
        updated.updatedAt = Date()
        upsertMemo(updated)
    }

    func togglePin(_ memo: EventMemo) {
        var updated = memo
        updated.isPinned.toggle()
        updated.updatedAt = Date()
        upsertMemo(updated)
    }

    func duplicateMemo(_ memo: EventMemo) {
        let copy = EventMemo(
            id: UUID(),
            title: memo.title,
            content: memo.content,
            tags: memo.tags,
            emoji: memo.emoji,
            createdAt: Date(),
            updatedAt: Date(),
            chronicleAt: Date(),
            isPinned: false,
            remindAt: nil
        )
        upsertMemo(copy)
    }

    func upsertNarrative(_ narrative: EventNarrative) {
        if let index = narratives.firstIndex(where: { $0.id == narrative.id }) {
            narratives[index] = narrative
        } else {
            narratives.insert(narrative, at: 0)
        }
        rememberTags(narrative.tags)
        touchActivity()
        persist(narratives, key: Keys.captions)
    }

    func deleteNarrative(_ narrative: EventNarrative) {
        narratives.removeAll { $0.id == narrative.id }
        touchActivity()
        persist(narratives, key: Keys.captions)
    }

    func duplicateNarrative(_ narrative: EventNarrative) {
        let copy = EventNarrative(
            id: UUID(),
            imageName: narrative.imageName,
            caption: narrative.caption,
            dateStamp: Date(),
            tags: narrative.tags,
            createdAt: Date()
        )
        upsertNarrative(copy)
    }

    func isFavourited(_ collectionID: String) -> Bool {
        favouritedCollections.contains { $0.id == collectionID }
    }

    func toggleFavourite(_ collectionID: String) {
        if let index = favouritedCollections.firstIndex(where: { $0.id == collectionID }) {
            favouritedCollections.remove(at: index)
        } else {
            favouritedCollections.insert(FavouritedMark(id: collectionID, markedAt: Date()), at: 0)
        }
        touchActivity()
        persist(favouritedCollections, key: Keys.favouritedCollections)
    }

    func setEventDate(_ date: Date?) {
        eventDate = date
        if let date {
            persist(date, key: Keys.eventDate)
        } else {
            defaults.removeObject(forKey: Keys.eventDate)
        }
    }

    func upsertChecklist(_ item: ChecklistItem) {
        if let index = checklist.firstIndex(where: { $0.id == item.id }) {
            checklist[index] = item
        } else {
            checklist.append(item)
        }
        persist(checklist, key: Keys.checklist)
    }

    func toggleChecklist(_ item: ChecklistItem) {
        var updated = item
        updated.isDone.toggle()
        upsertChecklist(updated)
    }

    func deleteChecklist(_ item: ChecklistItem) {
        checklist.removeAll { $0.id == item.id }
        persist(checklist, key: Keys.checklist)
    }

    func upsertVendor(_ vendor: VendorCard) {
        if let index = vendors.firstIndex(where: { $0.id == vendor.id }) {
            vendors[index] = vendor
        } else {
            vendors.insert(vendor, at: 0)
        }
        persist(vendors, key: Keys.vendors)
    }

    func deleteVendor(_ vendor: VendorCard) {
        vendors.removeAll { $0.id == vendor.id }
        persist(vendors, key: Keys.vendors)
    }

    func upsertEnvelope(_ envelope: BudgetEnvelope) {
        if let index = envelopes.firstIndex(where: { $0.id == envelope.id }) {
            envelopes[index] = envelope
        } else {
            envelopes.append(envelope)
        }
        persist(envelopes, key: Keys.envelopes)
    }

    func deleteEnvelope(_ envelope: BudgetEnvelope) {
        envelopes.removeAll { $0.id == envelope.id }
        persist(envelopes, key: Keys.envelopes)
    }

    func upsertBeat(_ beat: ShowBeat) {
        if let index = showBeats.firstIndex(where: { $0.id == beat.id }) {
            showBeats[index] = beat
        } else {
            showBeats.append(beat)
        }
        persist(showBeats, key: Keys.showBeats)
    }

    func deleteBeat(_ beat: ShowBeat) {
        showBeats.removeAll { $0.id == beat.id }
        persist(showBeats, key: Keys.showBeats)
    }

    func moveBeat(_ beat: ShowBeat, by offset: Int) {
        guard let index = showBeats.firstIndex(where: { $0.id == beat.id }) else { return }
        let next = index + offset
        guard showBeats.indices.contains(next) else { return }
        showBeats.swapAt(index, next)
        persist(showBeats, key: Keys.showBeats)
    }

    func upsertGuest(_ guest: GuestNote) {
        if let index = guests.firstIndex(where: { $0.id == guest.id }) {
            guests[index] = guest
        } else {
            guests.insert(guest, at: 0)
        }
        persist(guests, key: Keys.guests)
    }

    func deleteGuest(_ guest: GuestNote) {
        guests.removeAll { $0.id == guest.id }
        persist(guests, key: Keys.guests)
    }

    func upsertSwatch(_ swatch: MoodSwatch) {
        if let index = swatches.firstIndex(where: { $0.id == swatch.id }) {
            swatches[index] = swatch
        } else if swatches.count < 6 {
            swatches.append(swatch)
        }
        persist(swatches, key: Keys.swatches)
    }

    func deleteSwatch(_ swatch: MoodSwatch) {
        swatches.removeAll { $0.id == swatch.id }
        persist(swatches, key: Keys.swatches)
    }

    func resetAllData() {
        let keys = [
            Keys.memos,
            Keys.captions,
            Keys.favouritedCollections,
            Keys.recentlyUsedTags,
            Keys.preferredEmoji,
            Keys.lastActivityDate,
            Keys.eventDate,
            Keys.checklist,
            Keys.vendors,
            Keys.envelopes,
            Keys.showBeats,
            Keys.guests,
            Keys.swatches
        ]
        for key in keys {
            defaults.removeObject(forKey: key)
        }
        memos = []
        narratives = []
        favouritedCollections = []
        recentlyUsedTags = []
        preferredEmoji = "✦"
        lastActivityDate = nil
        eventDate = nil
        checklist = ChecklistItem.seeded()
        persist(checklist, key: Keys.checklist)
        vendors = []
        envelopes = []
        showBeats = []
        guests = []
        swatches = MoodSwatch.seeded()
        persist(swatches, key: Keys.swatches)
        ReminderScheduler.cancelAll()
        NotificationCenter.default.post(name: Notification.Name("dataReset"), object: nil)
    }

    func suggestedTags() -> [String] {
        var seen: [String] = []
        let pooled = recentlyUsedTags + memos.flatMap(\.tags)
        for tag in pooled {
            let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            if seen.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
                continue
            }
            seen.append(trimmed)
        }
        return Array(seen.prefix(16))
    }

    private func rememberTags(_ tags: [String]) {
        var next = recentlyUsedTags
        for tag in tags.reversed() {
            let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            next.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
            next.insert(trimmed, at: 0)
        }
        recentlyUsedTags = Array(next.prefix(16))
        persist(recentlyUsedTags, key: Keys.recentlyUsedTags)
    }

    private func touchActivity() {
        lastActivityDate = Date()
        persist(lastActivityDate, key: Keys.lastActivityDate)
    }

    private func loadAll() {
        memos = load([EventMemo].self, key: Keys.memos, fallback: [])
        narratives = load([EventNarrative].self, key: Keys.captions, fallback: [])
        favouritedCollections = load([FavouritedMark].self, key: Keys.favouritedCollections, fallback: [])
        recentlyUsedTags = load([String].self, key: Keys.recentlyUsedTags, fallback: [])
        preferredEmoji = load(String.self, key: Keys.preferredEmoji, fallback: "✦")
        lastActivityDate = load(Date?.self, key: Keys.lastActivityDate, fallback: nil)
        if let data = defaults.data(forKey: Keys.eventDate),
           let date = try? Self.decoder.decode(Date.self, from: data) {
            eventDate = date
        } else {
            eventDate = nil
        }
        checklist = load([ChecklistItem].self, key: Keys.checklist, fallback: [])
        if checklist.isEmpty {
            checklist = ChecklistItem.seeded()
            persist(checklist, key: Keys.checklist)
        }
        vendors = load([VendorCard].self, key: Keys.vendors, fallback: [])
        envelopes = load([BudgetEnvelope].self, key: Keys.envelopes, fallback: [])
        showBeats = load([ShowBeat].self, key: Keys.showBeats, fallback: [])
        guests = load([GuestNote].self, key: Keys.guests, fallback: [])
        swatches = load([MoodSwatch].self, key: Keys.swatches, fallback: [])
        if swatches.isEmpty {
            swatches = MoodSwatch.seeded()
            persist(swatches, key: Keys.swatches)
        }
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        guard let data = try? Self.encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func load<T: Decodable>(_ type: T.Type, key: String, fallback: T) -> T {
        guard let data = defaults.data(forKey: key) else { return fallback }
        return (try? Self.decoder.decode(type, from: data)) ?? fallback
    }
}
