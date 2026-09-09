import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Settings")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))

                    Text("Housekeeping for this planner — nothing more.")
                        .font(.body)
                        .foregroundColor(Color("AppTextSecondary"))

                    EditorialCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Count down to event day", isOn: eventDateEnabled)
                                .font(.body.weight(.semibold))
                                .foregroundColor(Color("AppTextPrimary"))
                                .tint(Color("AppPrimary"))
                            if store.eventDate != nil {
                                DatePicker(
                                    "Event day",
                                    selection: eventDateBinding,
                                    displayedComponents: .date
                                )
                                .font(.body)
                                .foregroundColor(Color("AppTextPrimary"))
                                .tint(Color("AppPrimary"))
                            }
                        }
                    }

                    GradientActionButton(title: "Rate Us", systemImage: "star") {
                        viewModel.requestReview()
                    }

                    GradientActionButton(title: "Privacy", systemImage: "hand.raised") {
                        viewModel.openPrivacy()
                    }

                    GradientActionButton(title: "Terms", systemImage: "doc.text") {
                        viewModel.openTerms()
                    }

                    Button {
                        viewModel.confirmReset = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset All Data")
                                .font(.body.weight(.semibold))
                        }
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
                .padding(20)
            }
            .screenCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))
                }
            }
            .tint(Color("AppPrimary"))
            .confirmationDialog(
                "Reset all saved memos, captions, favourites, and day tools?",
                isPresented: $viewModel.confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset All Data", role: .destructive) {
                    store.resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .screenBackground()
        .dismissKeyboardOnTap()
    }

    private var eventDateEnabled: Binding<Bool> {
        Binding(
            get: { store.eventDate != nil },
            set: { enabled in
                if enabled {
                    store.setEventDate(store.eventDate ?? Calendar.current.date(byAdding: .day, value: 60, to: Date()) ?? Date())
                } else {
                    store.setEventDate(nil)
                }
            }
        )
    }

    private var eventDateBinding: Binding<Date> {
        Binding(
            get: { store.eventDate ?? Date() },
            set: { store.setEventDate($0) }
        )
    }
}
