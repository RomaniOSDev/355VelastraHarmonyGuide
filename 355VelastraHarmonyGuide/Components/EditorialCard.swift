import SwiftUI

struct EditorialCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(.vertical, 14)
            .padding(.trailing, 14)
            .padding(.leading, 20)
            .background(
                LinearGradient(
                    colors: [Color("AppSurface"), Color("AppBackground")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(alignment: .leading) {
                Color("AppPrimary")
                    .frame(width: 6)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: Color.black.opacity(0.35), radius: 10, y: 6)
    }
}
