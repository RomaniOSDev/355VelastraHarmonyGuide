import Combine
import Foundation

@MainActor
final class NarrativeEditorViewModel: ObservableObject {
    let draftID: UUID
    let isNew: Bool

    @Published var imageName: String
    @Published var caption: String
    @Published var dateStamp: Date
    @Published var tags: [String]
    @Published var tagDraft: String = ""
    @Published var confirmDelete = false

    init(narrative: EventNarrative?) {
        if let narrative {
            draftID = narrative.id
            isNew = false
            imageName = narrative.imageName
            caption = narrative.caption
            dateStamp = narrative.dateStamp
            tags = narrative.tags
        } else {
            draftID = UUID()
            isNew = true
            imageName = NarrativeImage.tablescape.rawValue
            caption = ""
            dateStamp = Date()
            tags = []
        }
    }

    var canSave: Bool {
        !caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func applyTemplate(_ template: CaptionTemplate) {
        imageName = template.image.rawValue
        caption = template.text
        if !tags.contains(where: { $0.caseInsensitiveCompare(template.label) == .orderedSame }) {
            tags.append(template.label)
        }
    }

    func assembled(now: Date, existing: EventNarrative?) -> EventNarrative {
        EventNarrative(
            id: draftID,
            imageName: imageName,
            caption: caption.trimmingCharacters(in: .whitespacesAndNewlines),
            dateStamp: dateStamp,
            tags: tags,
            createdAt: existing?.createdAt ?? now
        )
    }
}
