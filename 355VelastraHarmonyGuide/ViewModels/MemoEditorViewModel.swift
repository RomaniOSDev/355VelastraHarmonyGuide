import Combine
import Foundation

@MainActor
final class MemoEditorViewModel: ObservableObject {
    let draftID: UUID
    let isNew: Bool

    @Published var title: String
    @Published var content: String
    @Published var emoji: String
    @Published var tags: [String]
    @Published var tagDraft: String = ""
    @Published var confirmDelete = false
    @Published var isPinned: Bool
    @Published var remindEnabled: Bool
    @Published var remindAt: Date

    static let palette = ["✦", "🕯", "🥂", "💐", "✉️", "🍽", "🌙", "🎻", "💌", "🌿"]

    init(memo: EventMemo?, preferredEmoji: String) {
        if let memo {
            draftID = memo.id
            isNew = false
            title = memo.title
            content = memo.content
            emoji = memo.emoji
            tags = memo.tags
            isPinned = memo.isPinned
            remindEnabled = memo.remindAt != nil
            remindAt = memo.remindAt ?? Date().addingTimeInterval(3600)
        } else {
            draftID = UUID()
            isNew = true
            title = ""
            content = ""
            emoji = preferredEmoji
            tags = []
            isPinned = false
            remindEnabled = false
            remindAt = Date().addingTimeInterval(3600)
        }
    }

    var canSave: Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedTitle.isEmpty && !tags.isEmpty
    }

    func assembled(now: Date, existing: EventMemo?) -> EventMemo {
        EventMemo(
            id: draftID,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: content.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: tags,
            emoji: emoji,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now,
            chronicleAt: existing?.chronicleAt ?? now,
            isPinned: isPinned,
            remindAt: remindEnabled ? remindAt : nil
        )
    }
}
