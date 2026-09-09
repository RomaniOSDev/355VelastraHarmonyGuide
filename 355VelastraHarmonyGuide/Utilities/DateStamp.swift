import Foundation

enum DateStamp {
    static func mixed(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    static func day(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
