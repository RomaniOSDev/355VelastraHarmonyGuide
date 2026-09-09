import Foundation

struct EventMemo: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var content: String
    var tags: [String]
    var emoji: String
    var createdAt: Date
    var updatedAt: Date
    var chronicleAt: Date
    var isPinned: Bool
    var remindAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, title, content, tags, emoji, createdAt, updatedAt, chronicleAt, isPinned, remindAt
    }

    init(
        id: UUID,
        title: String,
        content: String,
        tags: [String],
        emoji: String,
        createdAt: Date,
        updatedAt: Date,
        chronicleAt: Date,
        isPinned: Bool = false,
        remindAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.tags = tags
        self.emoji = emoji
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.chronicleAt = chronicleAt
        self.isPinned = isPinned
        self.remindAt = remindAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        tags = try container.decode([String].self, forKey: .tags)
        emoji = try container.decode(String.self, forKey: .emoji)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        chronicleAt = try container.decode(Date.self, forKey: .chronicleAt)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        remindAt = try container.decodeIfPresent(Date.self, forKey: .remindAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(tags, forKey: .tags)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(chronicleAt, forKey: .chronicleAt)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encodeIfPresent(remindAt, forKey: .remindAt)
    }
}
