import SwiftUI

struct SpotlightDetailView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.jumpToChronicle) private var jumpToChronicle
    let item: SpotlightItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BundledImageThumb(name: item.coverName)
                    .frame(height: 220)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.black.opacity(0.35), radius: 10, y: 6)

                Text(item.kicker.uppercased())
                    .font(.caption)
                    .foregroundColor(Color("AppPrimary"))

                Text(item.title)
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundColor(Color("AppTextPrimary"))

                EditorialCard {
                    Text(item.body)
                        .font(.body)
                        .foregroundColor(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                GradientActionButton(
                    title: store.isFavourited(item.id) ? "Remove from chronicle" : "Heart this collection",
                    systemImage: store.isFavourited(item.id) ? "heart.slash" : "heart.fill"
                ) {
                    store.toggleFavourite(item.id)
                    if store.isFavourited(item.id) {
                        SaveHaptic.play()
                        jumpToChronicle()
                    }
                }
            }
            .padding(20)
        }
        .screenCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    store.toggleFavourite(item.id)
                    if store.isFavourited(item.id) {
                        SaveHaptic.play()
                    }
                } label: {
                    Image(systemName: store.isFavourited(item.id) ? "heart.fill" : "heart")
                        .foregroundColor(Color("AppPrimary"))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(store.isFavourited(item.id) ? "Unfavourite" : "Favourite")
            }
        }
        .tint(Color("AppPrimary"))
    }
}
