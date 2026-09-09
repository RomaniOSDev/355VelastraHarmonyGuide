import SwiftUI

struct PillDock: View {
    let current: AppScreen
    let onSelect: (AppScreen) -> Void

    var body: some View {
        HStack(spacing: 0) {
            dockItem(title: "Home", symbol: "house", screen: .timeline)
            dockItem(title: "Memos", symbol: "note.text", screen: .memos)
            dockItem(title: "Captions", symbol: "text.bubble", screen: .captions)
            dockItem(title: "Stats", symbol: "chart.bar", screen: .stats)
            dockItem(title: "Settings", symbol: "gearshape", screen: .settings)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color("AppSurface"), Color("AppBackground")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.black.opacity(0.35), radius: 10, y: 6)
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.4), lineWidth: 1)
        )
    }

    private func dockItem(title: String, symbol: String, screen: AppScreen) -> some View {
        let selected = current == screen
        return Button {
            onSelect(screen)
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if selected {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 34, height: 34)
                    }
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(selected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                }
                .frame(height: 34)
                Text(title)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(selected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}
