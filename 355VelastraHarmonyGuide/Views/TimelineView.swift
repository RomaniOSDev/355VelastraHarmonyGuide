import SwiftUI

struct TimelineView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.openScreen) private var openScreen
    @StateObject private var viewModel = TimelineViewModel()
    @State private var memoToEdit: EventMemo?
    @State private var narrativeToEdit: EventNarrative?
    @State private var spotlightItem: SpotlightItem?
    @State private var showingMemoEditor = false
    @State private var showingNarrativeEditor = false

    var body: some View {
        NavigationStack {
            let entries = viewModel.entries(from: store)
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    if entries.isEmpty {
                        EditorialCard {
                            EmptyStateBlock(
                                symbol: "calendar.day.timeline.left",
                                message: "The chronicle is quiet. Compose a memo, caption a table, or heart a collection — they will land on this rail."
                            )
                        }
                        GradientActionButton(title: "Write a memo", systemImage: "square.and.pencil") {
                            memoToEdit = nil
                            showingMemoEditor = true
                        }
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                TimelineRailRow(isLast: index == entries.count - 1) {
                                    timelineCard(entry)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
            }
            .scrollIndicators(.hidden)
            .screenCanvas()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Chronicle")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))
                }
            }
            .tint(Color("AppPrimary"))
            .navigationDestination(for: DeskRoute.self) { route in
                switch route {
                case .checklist:
                    DayChecklistView()
                case .vendors:
                    VendorDeskView()
                case .budget:
                    BudgetDeskView()
                case .show:
                    RunOfShowView()
                case .guests:
                    GuestDeskView()
                case .palette:
                    MoodPaletteView()
                }
            }
            .sheet(isPresented: $showingMemoEditor) {
                MemoEditorView(memo: memoToEdit, preferredEmoji: store.preferredEmoji)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showingNarrativeEditor) {
                NarrativeEditorView(narrative: narrativeToEdit)
                    .environmentObject(store)
            }
            .sheet(item: $spotlightItem) { item in
                NavigationStack {
                    SpotlightDetailView(item: item)
                        .environmentObject(store)
                }
            }
        }
        .screenBackground()
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Color.clear
                .frame(maxWidth: .infinity)
                .frame(height: 168)
                .background {
                    Image("banner_tablescape")
                        .resizable()
                        .scaledToFill()
                }
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color.black.opacity(0.35), radius: 10, y: 6)

            Text("The Day’s Arc")
                .font(.system(.title, design: .serif))
                .foregroundColor(Color("AppTextPrimary"))

            if let line = countdownLine {
                Text(line)
                    .font(.body)
                    .foregroundColor(Color("AppPrimary"))
            }

            if let date = store.lastActivityDate {
                Text("Latest mark · \(DateStamp.mixed(date))")
                    .font(.body)
                    .foregroundColor(Color("AppTextSecondary"))
            } else {
                Text("Awaiting the first mark on the rail")
                    .font(.body)
                    .foregroundColor(Color("AppTextSecondary"))
            }

            HStack(spacing: 10) {
                Button {
                    openScreen(.spotlight)
                } label: {
                    DeskTile(title: "Collections", symbol: "rectangle.stack")
                }
                .buttonStyle(.plain)
                Button {
                    openScreen(.stats)
                } label: {
                    DeskTile(title: "Statistics", symbol: "chart.bar")
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                NavigationLink(value: DeskRoute.checklist) {
                    DeskTile(title: "Day checklist", symbol: "checkmark.circle")
                }
                .buttonStyle(.plain)
                NavigationLink(value: DeskRoute.vendors) {
                    DeskTile(title: "Vendors", symbol: "phone")
                }
                .buttonStyle(.plain)
                NavigationLink(value: DeskRoute.budget) {
                    DeskTile(title: "Budget", symbol: "tray.full")
                }
                .buttonStyle(.plain)
                NavigationLink(value: DeskRoute.show) {
                    DeskTile(title: "Run of show", symbol: "list.number")
                }
                .buttonStyle(.plain)
                NavigationLink(value: DeskRoute.guests) {
                    DeskTile(title: "Guest names", symbol: "text.book.closed")
                }
                .buttonStyle(.plain)
                NavigationLink(value: DeskRoute.palette) {
                    DeskTile(title: "Mood palette", symbol: "drop")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var countdownLine: String? {
        guard let eventDate = store.eventDate else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: eventDate)
        let days = calendar.dateComponents([.day], from: start, to: target).day ?? 0
        if days > 1 { return "\(days) days until the day" }
        if days == 1 { return "1 day until the day" }
        if days == 0 { return "The day is today" }
        let past = abs(days)
        return past == 1 ? "1 day since the day" : "\(past) days since the day"
    }

    @ViewBuilder
    private func timelineCard(_ entry: TimelineEntry) -> some View {
        switch entry.kind {
        case .memo(let memo):
            Button {
                memoToEdit = memo
                showingMemoEditor = true
            } label: {
                EditorialCard {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(memo.emoji)
                            Text("Memo")
                                .font(.caption)
                                .foregroundColor(Color("AppPrimary"))
                            if memo.isPinned {
                                Image(systemName: "pin.fill")
                                    .font(.caption2)
                                    .foregroundColor(Color("AppAccent"))
                            }
                            Spacer()
                            Text(DateStamp.day(entry.date))
                                .font(.caption)
                                .foregroundColor(Color("AppTextSecondary"))
                        }
                        Text(memo.title)
                            .font(.system(.title3, design: .serif))
                            .foregroundColor(Color("AppTextPrimary"))
                            .multilineTextAlignment(.leading)
                        if !memo.content.isEmpty {
                            Text(memo.content)
                                .font(.body)
                                .foregroundColor(Color("AppTextSecondary"))
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                        }
                        if !memo.tags.isEmpty {
                            Text(memo.tags.joined(separator: " · "))
                                .font(.caption)
                                .foregroundColor(Color("AppAccent"))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(.plain)

        case .narrative(let narrative):
            Button {
                narrativeToEdit = narrative
                showingNarrativeEditor = true
            } label: {
                EditorialCard {
                    HStack(alignment: .top, spacing: 12) {
                        BundledImageThumb(name: narrative.imageName)
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Caption")
                                .font(.caption)
                                .foregroundColor(Color("AppPrimary"))
                            Text(narrative.caption)
                                .font(.body)
                                .foregroundColor(Color("AppTextPrimary"))
                                .lineLimit(4)
                                .multilineTextAlignment(.leading)
                            Text(DateStamp.mixed(narrative.dateStamp))
                                .font(.caption)
                                .foregroundColor(Color("AppTextSecondary"))
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
            .buttonStyle(.plain)

        case .spotlight(let item):
            Button {
                spotlightItem = item
            } label: {
                EditorialCard {
                    HStack(alignment: .top, spacing: 12) {
                        BundledImageThumb(name: item.coverName)
                            .frame(width: 72, height: 88)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(Color("AppPrimary"))
                                Text("Collection")
                                    .font(.caption)
                                    .foregroundColor(Color("AppPrimary"))
                            }
                            Text(item.title)
                                .font(.system(.title3, design: .serif))
                                .foregroundColor(Color("AppTextPrimary"))
                                .multilineTextAlignment(.leading)
                            Text(item.kicker)
                                .font(.body)
                                .foregroundColor(Color("AppTextSecondary"))
                        }
                        Spacer(minLength: 0)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}
