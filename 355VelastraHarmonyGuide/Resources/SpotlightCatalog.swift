import Foundation

enum SpotlightCatalog {
    static let all: [SpotlightItem] = [
        SpotlightItem(
            id: "ceremony-walk",
            title: "Ceremony Walk",
            kicker: "Processional cadence",
            coverName: "tile_aisle",
            body: "Petal density, aisle width, and the pause before the first step. Keep the walk uncluttered so fabric and light can carry the room.",
            motifSymbol: "leaf"
        ),
        SpotlightItem(
            id: "tablescape-mood",
            title: "Tablescape Mood",
            kicker: "Linen, flame, place",
            coverName: "banner_tablescape",
            body: "Low vessels, staggered tapers, and a quiet place-card margin. The table should feel collected, never crowded — a still life guests can sit inside.",
            motifSymbol: "fork.knife"
        ),
        SpotlightItem(
            id: "stationery-desk",
            title: "Stationery Desk",
            kicker: "Ink, suite, seal",
            coverName: "tile_stationery",
            body: "Paper weight, wax temperature, and the order of the suite. A desk laid for signing and stamping keeps the paper story coherent from save-the-date to menu.",
            motifSymbol: "envelope.open"
        )
    ]

    static func item(id: String) -> SpotlightItem? {
        all.first { $0.id == id }
    }
}
