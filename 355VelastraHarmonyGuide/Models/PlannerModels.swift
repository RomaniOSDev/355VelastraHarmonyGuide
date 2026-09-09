import Foundation

enum DayAct: String, Codable, CaseIterable, Identifiable {
    case ceremony
    case cocktail
    case dinner

    var id: String { rawValue }

    var label: String {
        switch self {
        case .ceremony: return "Ceremony"
        case .cocktail: return "Cocktail"
        case .dinner: return "Dinner"
        }
    }
}

struct ChecklistItem: Identifiable, Codable, Equatable {
    var id: UUID
    var act: DayAct
    var title: String
    var isDone: Bool

    static func seeded() -> [ChecklistItem] {
        [
            ChecklistItem(id: UUID(), act: .ceremony, title: "Petals down the aisle", isDone: false),
            ChecklistItem(id: UUID(), act: .ceremony, title: "Processional cue", isDone: false),
            ChecklistItem(id: UUID(), act: .ceremony, title: "Vows copy at the lectern", isDone: false),
            ChecklistItem(id: UUID(), act: .cocktail, title: "Welcome pour ready", isDone: false),
            ChecklistItem(id: UUID(), act: .cocktail, title: "Place cards on the tray", isDone: false),
            ChecklistItem(id: UUID(), act: .dinner, title: "First dance cue", isDone: false),
            ChecklistItem(id: UUID(), act: .dinner, title: "Cake moment", isDone: false),
            ChecklistItem(id: UUID(), act: .dinner, title: "Thank-you from the table", isDone: false)
        ]
    }
}

struct VendorCard: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var role: String
    var phone: String
}

struct BudgetEnvelope: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var planned: Double
    var spent: Double

    var remaining: Double { planned - spent }
}

struct ShowBeat: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var pauseMinutes: Int
    var note: String
}

struct GuestNote: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var pronunciation: String
    var note: String
}

struct MoodSwatch: Identifiable, Codable, Equatable {
    var id: UUID
    var hex: String
    var label: String

    static func seeded() -> [MoodSwatch] {
        [
            MoodSwatch(id: UUID(), hex: "CF432B", label: "Coral flame"),
            MoodSwatch(id: UUID(), hex: "D96955", label: "Blush taper"),
            MoodSwatch(id: UUID(), hex: "F5EDE8", label: "Ivory linen"),
            MoodSwatch(id: UUID(), hex: "2B1A18", label: "Espresso wood"),
            MoodSwatch(id: UUID(), hex: "C4A574", label: "Warm gilt"),
            MoodSwatch(id: UUID(), hex: "6B7F5A", label: "Sage leaf")
        ]
    }
}

enum DeskRoute: String, Hashable {
    case checklist
    case vendors
    case budget
    case show
    case guests
    case palette
}

enum CaptionTemplate: String, CaseIterable, Identifiable {
    case aisle
    case tablescape
    case stationery

    var id: String { rawValue }

    var label: String {
        switch self {
        case .aisle: return "Aisle"
        case .tablescape: return "Tablescape"
        case .stationery: return "Stationery"
        }
    }

    var image: NarrativeImage {
        switch self {
        case .aisle: return .aisle
        case .tablescape: return .tablescape
        case .stationery: return .stationery
        }
    }

    var text: String {
        switch self {
        case .aisle:
            return "The walk stays uncluttered so fabric and light can carry the room."
        case .tablescape:
            return "Low vessels, staggered tapers, a still life guests can sit inside."
        case .stationery:
            return "Paper weight, wax temperature, the suite in order from seal to menu."
        }
    }
}
