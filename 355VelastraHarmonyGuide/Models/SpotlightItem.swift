import Foundation

struct SpotlightItem: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let kicker: String
    let coverName: String
    let body: String
    let motifSymbol: String
}

struct FavouritedMark: Identifiable, Codable, Equatable {
    var id: String
    var markedAt: Date
}
