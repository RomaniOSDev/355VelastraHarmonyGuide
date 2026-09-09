import SwiftUI

private struct ChronicleJumpKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

private struct OpenScreenKey: EnvironmentKey {
    static let defaultValue: (AppScreen) -> Void = { _ in }
}

extension EnvironmentValues {
    var jumpToChronicle: () -> Void {
        get { self[ChronicleJumpKey.self] }
        set { self[ChronicleJumpKey.self] = newValue }
    }

    var openScreen: (AppScreen) -> Void {
        get { self[OpenScreenKey.self] }
        set { self[OpenScreenKey.self] = newValue }
    }
}
