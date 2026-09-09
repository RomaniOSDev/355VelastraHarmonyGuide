import SwiftUI

struct NarrativeEditorView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.jumpToChronicle) private var jumpToChronicle
    @StateObject private var viewModel: NarrativeEditorViewModel

    init(narrative: EventNarrative?) {
        _viewModel = StateObject(wrappedValue: NarrativeEditorViewModel(narrative: narrative))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(viewModel.isNew ? "New Caption" : "Edit Caption")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))

                    Text("Photograph")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))

                    HStack(spacing: 10) {
                        ForEach(NarrativeImage.allCases) { option in
                            Button {
                                viewModel.imageName = option.rawValue
                            } label: {
                                VStack(spacing: 6) {
                                    BundledImageThumb(name: option.rawValue)
                                        .frame(height: 72)
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                                .stroke(
                                                    viewModel.imageName == option.rawValue
                                                        ? Color("AppPrimary")
                                                        : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                    Text(option.label)
                                        .font(.caption)
                                        .foregroundColor(Color("AppTextSecondary"))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("Templates")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))
                    HStack(spacing: 8) {
                        ForEach(CaptionTemplate.allCases) { template in
                            Button {
                                viewModel.applyTemplate(template)
                            } label: {
                                Text(template.label)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(Color("AppTextPrimary"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(Color("AppSurface"))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color("AppPrimary").opacity(0.5), lineWidth: 1)
                                    )
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text("Caption")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))
                    ZStack(alignment: .topLeading) {
                        if viewModel.caption.isEmpty {
                            Text("A line for this table, aisle, or desk")
                                .foregroundColor(Color("AppTextSecondary"))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $viewModel.caption)
                            .scrollContentBackground(.hidden)
                            .foregroundColor(Color("AppTextPrimary"))
                            .frame(minHeight: 140)
                    }
                    .padding(10)
                    .background(Color("AppBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    DatePicker(
                        "Date stamp",
                        selection: $viewModel.dateStamp,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .font(.body)
                    .foregroundColor(Color("AppTextPrimary"))
                    .tint(Color("AppPrimary"))
                    .padding(10)
                    .background(Color("AppBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    Text("Tags")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))
                    TagEditor(
                        tags: $viewModel.tags,
                        draft: $viewModel.tagDraft,
                        suggestions: store.suggestedTags()
                    )

                    GradientActionButton(
                        title: "Save caption",
                        systemImage: "checkmark",
                        isEnabled: viewModel.canSave,
                        action: save
                    )

                    if !viewModel.isNew {
                        GradientActionButton(title: "Duplicate caption", systemImage: "plus.square.on.square") {
                            if let existing = store.narratives.first(where: { $0.id == viewModel.draftID }) {
                                store.duplicateNarrative(existing)
                                SaveHaptic.play()
                                dismiss()
                            }
                        }

                        Button {
                            viewModel.confirmDelete = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete caption")
                            }
                            .font(.body.weight(.semibold))
                            .foregroundColor(Color("AppTextPrimary"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("AppSurface"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color("AppPrimary"), lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Color("AppTextSecondary"))
                }
            }
            .tint(Color("AppPrimary"))
            .alert("Delete this caption?", isPresented: $viewModel.confirmDelete) {
                Button("Delete", role: .destructive) {
                    if let existing = store.narratives.first(where: { $0.id == viewModel.draftID }) {
                        store.deleteNarrative(existing)
                    }
                    dismiss()
                }
                Button("Keep", role: .cancel) {}
            } message: {
                Text("The caption will leave the grid and the chronicle.")
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
                dismiss()
            }
        }
        .screenBackground()
        .preferredColorScheme(.dark)
        .dismissKeyboardOnTap()
    }

    private func save() {
        let existing = store.narratives.first { $0.id == viewModel.draftID }
        let narrative = viewModel.assembled(now: Date(), existing: existing)
        store.upsertNarrative(narrative)
        SaveHaptic.play()
        dismiss()
        jumpToChronicle()
    }
}
