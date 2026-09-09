import Combine
import Foundation

@MainActor
final class MemoGalleryViewModel: ObservableObject {
    @Published var showingEditor = false
    @Published var memoToEdit: EventMemo?
    @Published var pendingDelete: EventMemo?
    @Published var query = ""
    @Published var tagFilter: String?

    var isDeleteAlertPresented: Bool {
        get { pendingDelete != nil }
        set { if !newValue { pendingDelete = nil } }
    }

    func openCreate() {
        memoToEdit = nil
        showingEditor = true
    }

    func openEdit(_ memo: EventMemo) {
        memoToEdit = memo
        showingEditor = true
    }

    func visibleMemos(_ memos: [EventMemo]) -> [EventMemo] {
        memos.filter { memo in
            matchesQuery(memo) && matchesTag(memo)
        }
        .sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned {
                return lhs.isPinned && !rhs.isPinned
            }
            return lhs.updatedAt > rhs.updatedAt
        }
    }

    private func matchesQuery(_ memo: EventMemo) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return true }
        return memo.title.localizedCaseInsensitiveContains(trimmed)
            || memo.content.localizedCaseInsensitiveContains(trimmed)
            || memo.tags.contains { $0.localizedCaseInsensitiveContains(trimmed) }
    }

    private func matchesTag(_ memo: EventMemo) -> Bool {
        guard let tagFilter else { return true }
        return memo.tags.contains { $0.caseInsensitiveCompare(tagFilter) == .orderedSame }
    }
}
