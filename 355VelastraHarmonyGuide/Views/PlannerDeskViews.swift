import SwiftUI
import UIKit

struct DeskTile: View {
    let title: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: symbol)
                .font(.title3.weight(.semibold))
                .foregroundColor(Color("AppPrimary"))
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(Color("AppTextPrimary"))
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color("AppSurface"), Color("AppBackground")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color("AppPrimary").opacity(0.35), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct DayChecklistView: View {
    @EnvironmentObject private var store: DataStore
    @State private var draftTitle = ""
    @State private var draftAct: DayAct = .ceremony

    var body: some View {
        deskScroll("Day checklist") {
            VStack(alignment: .leading, spacing: 16) {
                EditorialCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Add a beat")
                            .font(.system(.headline, design: .serif))
                            .foregroundColor(Color("AppTextPrimary"))
                        Picker("Act", selection: $draftAct) {
                            ForEach(DayAct.allCases) { act in
                                Text(act.label).tag(act)
                            }
                        }
                        .pickerStyle(.segmented)
                        TextField("What must happen", text: $draftTitle)
                            .foregroundColor(Color("AppTextPrimary"))
                            .padding(10)
                            .background(Color("AppBackground"))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        GradientActionButton(title: "Add to the day", systemImage: "plus", isEnabled: canAdd) {
                            let item = ChecklistItem(
                                id: UUID(),
                                act: draftAct,
                                title: draftTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                                isDone: false
                            )
                            store.upsertChecklist(item)
                            draftTitle = ""
                            SaveHaptic.play()
                        }
                    }
                }

                ForEach(DayAct.allCases) { act in
                    let items = store.checklist.filter { $0.act == act }
                    VStack(alignment: .leading, spacing: 10) {
                        Text(act.label)
                            .font(.system(.title3, design: .serif))
                            .foregroundColor(Color("AppTextPrimary"))
                        if items.isEmpty {
                            Text("Nothing listed for this act yet.")
                                .font(.caption)
                                .foregroundColor(Color("AppTextSecondary"))
                        } else {
                            ForEach(items) { item in
                                EditorialCard {
                                    HStack(alignment: .top, spacing: 12) {
                                        Button {
                                            store.toggleChecklist(item)
                                        } label: {
                                            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                                .font(.title3)
                                                .foregroundColor(Color("AppPrimary"))
                                        }
                                        .buttonStyle(.plain)
                                        Text(item.title)
                                            .font(.body)
                                            .foregroundColor(Color("AppTextPrimary"))
                                            .strikethrough(item.isDone)
                                        Spacer(minLength: 0)
                                        Button {
                                            store.deleteChecklist(item)
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.caption.weight(.bold))
                                                .foregroundColor(Color("AppTextSecondary"))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var canAdd: Bool {
        !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct VendorDeskView: View {
    @EnvironmentObject private var store: DataStore
    @State private var name = ""
    @State private var role = ""
    @State private var phone = ""

    var body: some View {
        deskScroll("Vendors") {
            VStack(alignment: .leading, spacing: 16) {
                EditorialCard {
                    VStack(alignment: .leading, spacing: 10) {
                        field("Name", text: $name, hint: "Atelier, florist, kitchen")
                        field("Role", text: $role, hint: "Who they are on the day")
                        field("Phone", text: $phone, hint: "Direct line", keyboard: .phonePad)
                        GradientActionButton(title: "Save vendor", systemImage: "person.crop.rectangle", isEnabled: canSave) {
                            store.upsertVendor(
                                VendorCard(
                                    id: UUID(),
                                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                    role: role.trimmingCharacters(in: .whitespacesAndNewlines),
                                    phone: phone.trimmingCharacters(in: .whitespacesAndNewlines)
                                )
                            )
                            name = ""
                            role = ""
                            phone = ""
                            SaveHaptic.play()
                        }
                    }
                }

                if store.vendors.isEmpty {
                    EditorialCard {
                        EmptyStateBlock(symbol: "phone", message: "Keep the people who make the day reachable.")
                    }
                } else {
                    ForEach(store.vendors) { vendor in
                        EditorialCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(vendor.name)
                                    .font(.system(.title3, design: .serif))
                                    .foregroundColor(Color("AppTextPrimary"))
                                Text(vendor.role)
                                    .font(.body)
                                    .foregroundColor(Color("AppTextSecondary"))
                                HStack {
                                    if let url = telURL(vendor.phone) {
                                        Button {
                                            UIApplication.shared.open(url)
                                        } label: {
                                            Label(vendor.phone, systemImage: "phone.fill")
                                                .font(.caption.weight(.semibold))
                                                .foregroundColor(Color("AppPrimary"))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    Spacer()
                                    Button("Remove") {
                                        store.deleteVendor(vendor)
                                    }
                                    .font(.caption)
                                    .foregroundColor(Color("AppTextSecondary"))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func telURL(_ phone: String) -> URL? {
        let digits = phone.filter(\.isNumber)
        guard digits.count >= 3 else { return nil }
        return URL(string: "tel://\(digits)")
    }
}

struct BudgetDeskView: View {
    @EnvironmentObject private var store: DataStore
    @State private var title = ""
    @State private var planned = ""
    @State private var spent = ""

    var body: some View {
        deskScroll("Budget") {
            VStack(alignment: .leading, spacing: 16) {
                EditorialCard {
                    VStack(alignment: .leading, spacing: 10) {
                        field("Envelope", text: $title, hint: "Florals, linen, kitchen")
                        field("Planned", text: $planned, hint: "0", keyboard: .decimalPad)
                        field("Spent", text: $spent, hint: "0", keyboard: .decimalPad)
                        GradientActionButton(title: "Save envelope", systemImage: "tray.full", isEnabled: canSave) {
                            store.upsertEnvelope(
                                BudgetEnvelope(
                                    id: UUID(),
                                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                    planned: Double(planned.replacingOccurrences(of: ",", with: ".")) ?? 0,
                                    spent: Double(spent.replacingOccurrences(of: ",", with: ".")) ?? 0
                                )
                            )
                            title = ""
                            planned = ""
                            spent = ""
                            SaveHaptic.play()
                        }
                    }
                }

                if store.envelopes.isEmpty {
                    EditorialCard {
                        EmptyStateBlock(symbol: "tray", message: "Give each article of the day its own envelope.")
                    }
                } else {
                    ForEach(store.envelopes) { envelope in
                        EditorialCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(envelope.title)
                                        .font(.system(.title3, design: .serif))
                                        .foregroundColor(Color("AppTextPrimary"))
                                    Spacer()
                                    Button("Remove") { store.deleteEnvelope(envelope) }
                                        .font(.caption)
                                        .foregroundColor(Color("AppTextSecondary"))
                                }
                                Text("Planned \(format(envelope.planned)) · spent \(format(envelope.spent))")
                                    .font(.caption)
                                    .foregroundColor(Color("AppTextSecondary"))
                                ProgressView(value: progress(envelope))
                                    .tint(Color("AppPrimary"))
                                Text(envelope.remaining >= 0 ? "Remaining \(format(envelope.remaining))" : "Over by \(format(abs(envelope.remaining)))")
                                    .font(.caption)
                                    .foregroundColor(envelope.remaining >= 0 ? Color("AppAccent") : Color("AppPrimary"))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func progress(_ envelope: BudgetEnvelope) -> Double {
        guard envelope.planned > 0 else { return envelope.spent > 0 ? 1 : 0 }
        return min(max(envelope.spent / envelope.planned, 0), 1)
    }

    private func format(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2)))
    }
}

struct RunOfShowView: View {
    @EnvironmentObject private var store: DataStore
    @State private var title = ""
    @State private var pause = 5
    @State private var note = ""

    var body: some View {
        deskScroll("Run of show") {
            VStack(alignment: .leading, spacing: 16) {
                EditorialCard {
                    VStack(alignment: .leading, spacing: 10) {
                        field("Cue", text: $title, hint: "Processional, first look, toasts")
                        Stepper("Pause \(pause) min", value: $pause, in: 0...60)
                            .foregroundColor(Color("AppTextPrimary"))
                        field("Note", text: $note, hint: "Who moves, who waits")
                        GradientActionButton(title: "Add cue", systemImage: "list.number", isEnabled: canSave) {
                            store.upsertBeat(
                                ShowBeat(
                                    id: UUID(),
                                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                    pauseMinutes: pause,
                                    note: note.trimmingCharacters(in: .whitespacesAndNewlines)
                                )
                            )
                            title = ""
                            note = ""
                            pause = 5
                            SaveHaptic.play()
                        }
                    }
                }

                if store.showBeats.isEmpty {
                    EditorialCard {
                        EmptyStateBlock(symbol: "list.bullet.rectangle", message: "Order the day: who enters, where the pause sits.")
                    }
                } else {
                    ForEach(Array(store.showBeats.enumerated()), id: \.element.id) { index, beat in
                        EditorialCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("\(index + 1). \(beat.title)")
                                        .font(.system(.title3, design: .serif))
                                        .foregroundColor(Color("AppTextPrimary"))
                                    Spacer()
                                    Button("Remove") { store.deleteBeat(beat) }
                                        .font(.caption)
                                        .foregroundColor(Color("AppTextSecondary"))
                                }
                                Text("Pause \(beat.pauseMinutes) min")
                                    .font(.caption)
                                    .foregroundColor(Color("AppPrimary"))
                                if !beat.note.isEmpty {
                                    Text(beat.note)
                                        .font(.body)
                                        .foregroundColor(Color("AppTextSecondary"))
                                }
                                HStack {
                                    Button("Up") { store.moveBeat(beat, by: -1) }
                                        .disabled(index == 0)
                                    Button("Down") { store.moveBeat(beat, by: 1) }
                                        .disabled(index == store.showBeats.count - 1)
                                }
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Color("AppAccent"))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct GuestDeskView: View {
    @EnvironmentObject private var store: DataStore
    @State private var name = ""
    @State private var pronunciation = ""
    @State private var note = ""

    var body: some View {
        deskScroll("Guest names") {
            VStack(alignment: .leading, spacing: 16) {
                EditorialCard {
                    VStack(alignment: .leading, spacing: 10) {
                        field("Name", text: $name, hint: "As written")
                        field("Say it", text: $pronunciation, hint: "How it should be spoken")
                        field("Note", text: $note, hint: "Table, toast, kinship")
                        GradientActionButton(title: "Save name", systemImage: "text.book.closed", isEnabled: canSave) {
                            store.upsertGuest(
                                GuestNote(
                                    id: UUID(),
                                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                    pronunciation: pronunciation.trimmingCharacters(in: .whitespacesAndNewlines),
                                    note: note.trimmingCharacters(in: .whitespacesAndNewlines)
                                )
                            )
                            name = ""
                            pronunciation = ""
                            note = ""
                            SaveHaptic.play()
                        }
                    }
                }

                if store.guests.isEmpty {
                    EditorialCard {
                        EmptyStateBlock(symbol: "mouth", message: "Keep a spoken form for names that should not be guessed.")
                    }
                } else {
                    ForEach(store.guests) { guest in
                        EditorialCard {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(guest.name)
                                        .font(.system(.title3, design: .serif))
                                        .foregroundColor(Color("AppTextPrimary"))
                                    Spacer()
                                    Button("Remove") { store.deleteGuest(guest) }
                                        .font(.caption)
                                        .foregroundColor(Color("AppTextSecondary"))
                                }
                                if !guest.pronunciation.isEmpty {
                                    Text(guest.pronunciation)
                                        .font(.system(.body, design: .serif).italic())
                                        .foregroundColor(Color("AppPrimary"))
                                }
                                if !guest.note.isEmpty {
                                    Text(guest.note)
                                        .font(.body)
                                        .foregroundColor(Color("AppTextSecondary"))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct MoodPaletteView: View {
    @EnvironmentObject private var store: DataStore
    @State private var hex = ""
    @State private var label = ""

    var body: some View {
        deskScroll("Mood palette") {
            VStack(alignment: .leading, spacing: 16) {
                EditorialCard {
                    VStack(alignment: .leading, spacing: 10) {
                        field("Label", text: $label, hint: "Linen, taper, leaf")
                        field("Hex", text: $hex, hint: "C4A574", keyboard: .asciiCapable)
                        GradientActionButton(
                            title: "Save shade",
                            systemImage: "drop",
                            isEnabled: canSave
                        ) {
                            store.upsertSwatch(
                                MoodSwatch(
                                    id: UUID(),
                                    hex: MoodSwatchColor.normalized(hex),
                                    label: label.trimmingCharacters(in: .whitespacesAndNewlines)
                                )
                            )
                            hex = ""
                            label = ""
                            SaveHaptic.play()
                        }
                        if store.swatches.count >= 6 {
                            Text("Six shades is enough — remove one to add another.")
                                .font(.caption)
                                .foregroundColor(Color("AppTextSecondary"))
                        }
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(store.swatches) { swatch in
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(hex: swatch.hex))
                                .frame(height: 72)
                            Text(swatch.label)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(Color("AppTextPrimary"))
                            Text("#\(swatch.hex)")
                                .font(.caption2)
                                .foregroundColor(Color("AppTextSecondary"))
                            Button("Remove") { store.deleteSwatch(swatch) }
                                .font(.caption)
                                .foregroundColor(Color("AppTextSecondary"))
                        }
                        .padding(10)
                        .background(Color("AppSurface"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
        }
    }

    private var canSave: Bool {
        store.swatches.count < 6
            && !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && MoodSwatchColor.isValid(hex)
    }
}

private func deskScroll<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    ScrollView {
        content()
            .padding(.horizontal, 18)
            .padding(.top, 12)
            .padding(.bottom, 24)
    }
    .scrollIndicators(.hidden)
    .screenCanvas()
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(.system(.headline, design: .serif))
                .foregroundColor(Color("AppTextPrimary"))
        }
    }
    .tint(Color("AppPrimary"))
    .dismissKeyboardOnTap()
}

private func field(_ title: String, text: Binding<String>, hint: String, keyboard: UIKeyboardType = .default) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(.system(.headline, design: .serif))
            .foregroundColor(Color("AppTextPrimary"))
        TextField(hint, text: text)
            .foregroundColor(Color("AppTextPrimary"))
            .keyboardType(keyboard)
            .textInputAutocapitalization(keyboard == .default ? .sentences : .never)
            .disableAutocorrection(keyboard != .default)
            .padding(10)
            .background(Color("AppBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private enum MoodSwatchColor {
    static func normalized(_ raw: String) -> String {
        raw.trimmingCharacters(in: CharacterSet.alphanumerics.inverted).uppercased()
    }

    static func isValid(_ raw: String) -> Bool {
        let cleaned = normalized(raw)
        return cleaned.count == 6 && cleaned.allSatisfy(\.isHexDigit)
    }
}

extension Color {
    init(hex: String) {
        let cleaned = MoodSwatchColor.normalized(hex)
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}
