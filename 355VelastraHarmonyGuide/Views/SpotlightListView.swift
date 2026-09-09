import SwiftUI

struct SpotlightListView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.openScreen) private var openScreen
    @StateObject private var viewModel = SpotlightViewModel()

    var body: some View {
        NavigationStack {
            let items = viewModel.visibleItems(favouritedIDs: Set(store.favouritedCollections.map(\.id)))
            List {
                searchField
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 18, bottom: 4, trailing: 18))

                favouritesChip
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 18, bottom: 8, trailing: 18))

                if items.isEmpty {
                    EditorialCard {
                        EmptyStateBlock(
                            symbol: "magnifyingglass",
                            message: "No collections match that search."
                        )
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18))
                } else {
                    ForEach(items) { item in
                        HStack(alignment: .top, spacing: 8) {
                            NavigationLink(value: item) {
                                EditorialCard {
                                    HStack(alignment: .top, spacing: 12) {
                                        BundledImageThumb(name: item.coverName)
                                            .frame(width: 84, height: 96)
                                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(item.title)
                                                .font(.system(.title3, design: .serif))
                                                .foregroundColor(Color("AppTextPrimary"))
                                            Text(item.kicker)
                                                .font(.body)
                                                .foregroundColor(Color("AppTextSecondary"))
                                        }
                                        Spacer(minLength: 0)
                                    }
                                }
                            }
                            .buttonStyle(.plain)

                            Button {
                                store.toggleFavourite(item.id)
                                if store.isFavourited(item.id) {
                                    SaveHaptic.play()
                                }
                            } label: {
                                Image(systemName: store.isFavourited(item.id) ? "heart.fill" : "heart")
                                    .font(.title3)
                                    .foregroundColor(Color("AppPrimary"))
                                    .padding(8)
                                    .background(Color("AppBackground"))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(store.isFavourited(item.id) ? "Unfavourite" : "Favourite")
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                store.toggleFavourite(item.id)
                                if store.isFavourited(item.id) {
                                    SaveHaptic.play()
                                }
                            } label: {
                                Label(
                                    store.isFavourited(item.id) ? "Unfavourite" : "Favourite",
                                    systemImage: store.isFavourited(item.id) ? "heart.slash" : "heart.fill"
                                )
                            }
                            .tint(Color("AppPrimary"))
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .screenCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Home") {
                        openScreen(.timeline)
                    }
                    .foregroundColor(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .principal) {
                    Text("Event Spotlight")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))
                }
            }
            .tint(Color("AppPrimary"))
            .navigationDestination(for: SpotlightItem.self) { item in
                SpotlightDetailView(item: item)
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
                viewModel.clearQuery()
            }
        }
        .screenBackground()
        .dismissKeyboardOnTap()
    }

    private var favouritesChip: some View {
        Button {
            viewModel.favouritesOnly.toggle()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: viewModel.favouritesOnly ? "heart.fill" : "heart")
                Text(viewModel.favouritesOnly ? "Hearts only" : "All collections")
                    .font(.caption)
            }
            .foregroundColor(Color("AppTextPrimary"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(viewModel.favouritesOnly ? Color("AppPrimary") : Color("AppSurface"))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color("AppPrimary").opacity(0.45), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("AppTextSecondary"))
            TextField("Search collections", text: $viewModel.query)
                .foregroundColor(Color("AppTextPrimary"))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.35), lineWidth: 1)
        )
    }
}
