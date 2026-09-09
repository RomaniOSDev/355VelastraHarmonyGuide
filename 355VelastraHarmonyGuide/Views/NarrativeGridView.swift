import SwiftUI

struct NarrativeGridView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel = NarrativeGridViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if store.narratives.isEmpty {
                    ScrollView {
                        EditorialCard {
                            EmptyStateBlock(
                                symbol: "plus.bubble.fill",
                                message: "Add captions to your event photos!"
                            )
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 24)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 14) {
                            ForEach(store.narratives) { narrative in
                                Button {
                                    viewModel.openEdit(narrative)
                                } label: {
                                    EditorialCard {
                                        VStack(alignment: .leading, spacing: 8) {
                                            BundledImageThumb(name: narrative.imageName)
                                                .frame(height: 96)
                                                .frame(maxWidth: .infinity)
                                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                            Text(narrative.caption)
                                                .font(.body)
                                                .foregroundColor(Color("AppTextPrimary"))
                                                .lineLimit(3)
                                                .multilineTextAlignment(.leading)
                                            Text(DateStamp.day(narrative.dateStamp))
                                                .font(.caption)
                                                .foregroundColor(Color("AppTextSecondary"))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button {
                                        store.duplicateNarrative(narrative)
                                        SaveHaptic.play()
                                    } label: {
                                        Label("Duplicate", systemImage: "plus.square.on.square")
                                    }
                                    Button(role: .destructive) {
                                        viewModel.pendingDelete = narrative
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 12)
                    }
                }
            }
            .screenCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Event Narratives")
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
                    .accessibilityLabel("Add caption")
                }
            }
            .tint(Color("AppPrimary"))
            .sheet(isPresented: $viewModel.showingEditor) {
                NarrativeEditorView(narrative: viewModel.narrativeToEdit)
                    .environmentObject(store)
            }
            .alert("Delete this caption?", isPresented: deleteAlertBinding) {
                Button("Delete", role: .destructive) {
                    if let narrative = viewModel.pendingDelete {
                        store.deleteNarrative(narrative)
                    }
                    viewModel.pendingDelete = nil
                }
                Button("Keep", role: .cancel) {
                    viewModel.pendingDelete = nil
                }
            } message: {
                Text("The caption will leave the grid and the chronicle.")
            }
        }
        .screenBackground()
    }

    private var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.pendingDelete != nil },
            set: { if !$0 { viewModel.pendingDelete = nil } }
        )
    }
}
