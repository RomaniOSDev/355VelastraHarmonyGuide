import Foundation

struct EventNarrative: Identifiable, Codable, Equatable {
    var id: UUID
    var imageName: String
    var caption: String
    var dateStamp: Date
    var tags: [String]
    var createdAt: Date
}

enum NarrativeImage: String, CaseIterable, Identifiable {
    case aisle = "tile_aisle"
    case stationery = "tile_stationery"
    case tablescape = "banner_tablescape"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .aisle:
            return "Aisle"
        case .stationery:
            return "Stationery"
        case .tablescape:
            return "Tablescape"
        }
    }
}
