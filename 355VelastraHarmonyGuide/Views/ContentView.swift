import SwiftUI

struct ContentView: View {
    @StateObject private var dataStore = DataStore()
    @State private var screen: AppScreen = .timeline

    var body: some View {
        ZStack(alignment: .bottom) {
            ScreenBackdrop()

            Group {
                switch screen {
                case .timeline:
                    TimelineView()
                case .memos:
                    MemoGalleryView()
                case .captions:
                    NarrativeGridView()
                case .spotlight:
                    SpotlightListView()
                case .stats:
                    StatsView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            PillDock(current: screen) { target in
                screen = target
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 18)
        }
        .environmentObject(dataStore)
        .environment(\.jumpToChronicle, { screen = .timeline })
        .environment(\.openScreen, { screen = $0 })
        .preferredColorScheme(.dark)
        .dismissKeyboardOnTap()
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
            screen = .timeline
        }
    }
}
