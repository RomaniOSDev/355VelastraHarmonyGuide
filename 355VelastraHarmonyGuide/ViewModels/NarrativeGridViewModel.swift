import Combine
import Foundation

@MainActor
final class NarrativeGridViewModel: ObservableObject {
    @Published var showingEditor = false
    @Published var narrativeToEdit: EventNarrative?
    @Published var pendingDelete: EventNarrative?

    var isDeleteAlertPresented: Bool {
        get { pendingDelete != nil }
        set { if !newValue { pendingDelete = nil } }
    }

    func openCreate() {
        narrativeToEdit = nil
        showingEditor = true
    }

    func openEdit(_ narrative: EventNarrative) {
        narrativeToEdit = narrative
        showingEditor = true
    }
}
