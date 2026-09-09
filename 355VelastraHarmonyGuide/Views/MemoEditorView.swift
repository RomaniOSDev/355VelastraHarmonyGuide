import SwiftUI

struct MemoEditorView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.jumpToChronicle) private var jumpToChronicle
    @StateObject private var viewModel: MemoEditorViewModel

    init(memo: EventMemo?, preferredEmoji: String) {
        _viewModel = StateObject(wrappedValue: MemoEditorViewModel(memo: memo, preferredEmoji: preferredEmoji))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(viewModel.isNew ? "New Memo" : "Memo Detail")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))

                    emojiRow

                    labeledField("Title") {
                        TextField("Ceremony notes", text: $viewModel.title)
                            .foregroundColor(Color("AppTextPrimary"))
                    }

                    labeledField("Content") {
                        ZStack(alignment: .topLeading) {
                            if viewModel.content.isEmpty {
                                Text("What should be remembered")
                                    .foregroundColor(Color("AppTextSecondary"))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }
                            TextEditor(text: $viewModel.content)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(Color("AppTextPrimary"))
                                .frame(minHeight: 120)
                        }
                    }

                    Text("Tags")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))
                    TagEditor(
                        tags: $viewModel.tags,
                        draft: $viewModel.tagDraft,
                        suggestions: store.suggestedTags()
                    )
                    if viewModel.tags.isEmpty {
                        Text("At least one tag is required.")
                            .font(.caption)
                            .foregroundColor(Color("AppPrimary"))
                    }

                    Toggle("Pin to the top of the chronicle", isOn: $viewModel.isPinned)
                        .font(.body)
                        .foregroundColor(Color("AppTextPrimary"))
                        .tint(Color("AppPrimary"))

                    Toggle("Remind me", isOn: Binding(
                        get: { viewModel.remindEnabled },
                        set: { enabled in
                            viewModel.remindEnabled = enabled
                            if enabled {
                                ReminderScheduler.requestAccess()
                            }
                        }
                    ))
                        .font(.body)
                        .foregroundColor(Color("AppTextPrimary"))
                        .tint(Color("AppPrimary"))
                    if viewModel.remindEnabled {
                        DatePicker(
                            "When",
                            selection: $viewModel.remindAt,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .font(.body)
                        .foregroundColor(Color("AppTextPrimary"))
                        .tint(Color("AppPrimary"))
                        .padding(10)
                        .background(Color("AppBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    GradientActionButton(
                        title: "Save memo",
                        systemImage: "checkmark",
                        isEnabled: viewModel.canSave,
                        action: save
                    )

                    if !viewModel.isNew {
                        GradientActionButton(title: "Send to timeline", systemImage: "calendar.day.timeline.left") {
                            let existing = store.memos.first { $0.id == viewModel.draftID }
                            let memo = viewModel.assembled(now: Date(), existing: existing)
                            store.sendMemoToTimeline(memo)
                            SaveHaptic.play()
                            dismiss()
                            jumpToChronicle()
                        }

                        GradientActionButton(title: "Duplicate memo", systemImage: "plus.square.on.square") {
                            if let existing = store.memos.first(where: { $0.id == viewModel.draftID }) {
                                store.duplicateMemo(existing)
                                SaveHaptic.play()
                                dismiss()
                            }
                        }

                        Button {
                            viewModel.confirmDelete = true
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete memo")
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
            .alert("Delete this memo?", isPresented: $viewModel.confirmDelete) {
                Button("Delete", role: .destructive) {
                    if let existing = store.memos.first(where: { $0.id == viewModel.draftID }) {
                        store.deleteMemo(existing)
                    }
                    dismiss()
                }
                Button("Keep", role: .cancel) {}
            } message: {
                Text("This mark will leave the gallery and the chronicle.")
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("dataReset"))) { _ in
                dismiss()
            }
        }
        .screenBackground()
        .preferredColorScheme(.dark)
        .dismissKeyboardOnTap()
    }

    private var emojiRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mark")
                .font(.system(.headline, design: .serif))
                .foregroundColor(Color("AppTextPrimary"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MemoEditorViewModel.palette, id: \.self) { mark in
                        Button {
                            viewModel.emoji = mark
                        } label: {
                            Text(mark)
                                .font(.title3)
                                .frame(width: 44, height: 44)
                                .background(
                                    LinearGradient(
                                        colors: viewModel.emoji == mark
                                            ? [Color("AppPrimary"), Color("AppAccent")]
                                            : [Color("AppSurface"), Color("AppBackground")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func labeledField<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.headline, design: .serif))
                .foregroundColor(Color("AppTextPrimary"))
            content()
                .padding(10)
                .background(Color("AppBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    private func save() {
        let existing = store.memos.first { $0.id == viewModel.draftID }
        let memo = viewModel.assembled(now: Date(), existing: existing)
        store.upsertMemo(memo)
        SaveHaptic.play()
        dismiss()
        jumpToChronicle()
    }
}
