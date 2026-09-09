import SwiftUI

struct TimelineRailRow<Content: View>: View {
    let isLast: Bool
    @ViewBuilder var content: Content

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(Color("AppPrimary"))
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .stroke(Color("AppAccent"), lineWidth: 1)
                    )
                Rectangle()
                    .fill(Color("AppPrimary"))
                    .frame(width: 3)
                    .frame(maxHeight: .infinity)
                    .opacity(isLast ? 0.25 : 1)
            }
            .frame(width: 14)

            content
                .padding(.bottom, isLast ? 8 : 18)
        }
    }
}
