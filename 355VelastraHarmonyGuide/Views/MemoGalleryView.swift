import SwiftUI

struct MemoGalleryView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel = MemoGalleryViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if store.memos.isEmpty {
                    ScrollView {
                        EditorialCard {
                            EmptyStateBlock(
                                symbol: "square.and.pencil",
                                message: "No entries yet? Tap + to add your first Event Memo!"
                            )
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 24)
                    }
                    .screenCanvas()
                } else {
                    let visible = viewModel.visibleMemos(store.memos)
                    List {
                        searchField
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 18, bottom: 4, trailing: 18))

                        if galleryTags.isEmpty == false {
                            tagFilters
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 0, leading: 18, bottom: 8, trailing: 18))
                        }

                        if visible.isEmpty {
                            EditorialCard {
                                EmptyStateBlock(
                                    symbol: "magnifyingglass",
                                    message: "No memos match that search."
                                )
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18))
                        } else {
                            ForEach(visible) { memo in
                                Button {
                                    viewModel.openEdit(memo)
                                } label: {
                                    EditorialCard {
                                        VStack(alignment: .leading, spacing: 8) {
                                            HStack {
                                                Text(memo.emoji)
                                                Text(memo.title)
                                                    .font(.system(.title3, design: .serif))
                                                    .foregroundColor(Color("AppTextPrimary"))
                                                if memo.isPinned {
                                                    Image(systemName: "pin.fill")
                                                        .font(.caption2)
                                                        .foregroundColor(Color("AppAccent"))
                                                }
                                                Spacer()
                                            }
                                            if !memo.content.isEmpty {
                                                Text(memo.content)
                                                    .font(.body)
                                                    .foregroundColor(Color("AppTextSecondary"))
                                                    .lineLimit(2)
                                            }
                                            Text(memo.tags.joined(separator: " · "))
                                                .font(.caption)
                                                .foregroundColor(Color("AppAccent"))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 8, leading: 18, bottom: 8, trailing: 18))
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        store.togglePin(memo)
                                    } label: {
                                        Label(memo.isPinned ? "Unpin" : "Pin", systemImage: "pin")
                                    }
                                    .tint(Color("AppAccent"))
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        viewModel.pendingDelete = memo
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    Button {
                                        store.duplicateMemo(memo)
                                        SaveHaptic.play()
                                    } label: {
                                        Label("Duplicate", systemImage: "plus.square.on.square")
                                    }
                                    .tint(Color("AppPrimary"))
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .screenCanvas()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Event Memos")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.openCreate()
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color("AppTextPrimary"))
                            .padding(8)
                            .background(
                                LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Add memo")
                }
            }
            .tint(Color("AppPrimary"))
            .sheet(isPresented: $viewModel.showingEditor) {
                MemoEditorView(memo: viewModel.memoToEdit, preferredEmoji: store.preferredEmoji)
                    .environmentObject(store)
            }
            .alert("Delete this memo?", isPresented: deleteAlertBinding) {
                Button("Delete", role: .destructive) {
                    if let memo = viewModel.pendingDelete {
                        store.deleteMemo(memo)
                    }
                    viewModel.pendingDelete = nil
                }
                Button("Keep", role: .cancel) {
                    viewModel.pendingDelete = nil
                }
            } message: {
                Text("This mark will leave the gallery and the chronicle.")
            }
        }
        .screenBackground()
        .dismissKeyboardOnTap()
    }

    private var galleryTags: [String] {
        var seen: [String] = []
        for tag in store.memos.flatMap(\.tags) {
            if seen.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) {
                continue
            }
            seen.append(tag)
        }
        return seen
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color("AppTextSecondary"))
            TextField("Search memos", text: $viewModel.query)
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

    private var tagFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(galleryTags, id: \.self) { tag in
                    let selected = viewModel.tagFilter?.caseInsensitiveCompare(tag) == .orderedSame
                    Button {
                        if selected {
                            viewModel.tagFilter = nil
                        } else {
                            viewModel.tagFilter = tag
                        }
                    } label: {
                        Text(tag)
                            .font(.caption)
                            .foregroundColor(Color("AppTextPrimary"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(selected ? Color("AppPrimary") : Color("AppSurface"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.pendingDelete != nil },
            set: { if !$0 { viewModel.pendingDelete = nil } }
        )
    }
}
