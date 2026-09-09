import Charts
import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            let days = viewModel.activity(from: store)
            let mix = viewModel.mix(from: store)
            let tags = viewModel.topTags(from: store)
            let hasMarks = store.memos.isEmpty == false || store.narratives.isEmpty == false || store.favouritedCollections.isEmpty == false

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Planning pulse")
                        .font(.system(.title, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))

                    if let line = viewModel.countdownLine(eventDate: store.eventDate) {
                        EditorialCard {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Event day")
                                    .font(.caption)
                                    .foregroundColor(Color("AppPrimary"))
                                Text(line)
                                    .font(.system(.title3, design: .serif))
                                    .foregroundColor(Color("AppTextPrimary"))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    HStack(spacing: 10) {
                        summaryTile(title: "Memos", value: "\(store.memos.count)")
                        summaryTile(title: "Captions", value: "\(store.narratives.count)")
                        summaryTile(title: "Hearts", value: "\(store.favouritedCollections.count)")
                    }

                    if hasMarks {
                        EditorialCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Last 14 days")
                                    .font(.system(.headline, design: .serif))
                                    .foregroundColor(Color("AppTextPrimary"))
                                Chart {
                                    ForEach(days) { day in
                                        BarMark(
                                            x: .value("Day", day.day, unit: .day),
                                            y: .value("Count", day.memos)
                                        )
                                        .foregroundStyle(by: .value("Kind", "Memos"))
                                        BarMark(
                                            x: .value("Day", day.day, unit: .day),
                                            y: .value("Count", day.captions)
                                        )
                                        .foregroundStyle(by: .value("Kind", "Captions"))
                                    }
                                }
                                .chartForegroundStyleScale([
                                    "Memos": Color("AppPrimary"),
                                    "Captions": Color("AppAccent")
                                ])
                                .chartLegend(position: .top, alignment: .leading)
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day, count: 3)) { _ in
                                        AxisGridLine().foregroundStyle(Color("AppPrimary").opacity(0.18))
                                        AxisValueLabel(format: .dateTime.month(.abbreviated).day(), centered: true)
                                            .foregroundStyle(Color("AppTextSecondary"))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks(position: .leading) { _ in
                                        AxisGridLine().foregroundStyle(Color("AppPrimary").opacity(0.18))
                                        AxisValueLabel()
                                            .foregroundStyle(Color("AppTextSecondary"))
                                    }
                                }
                                .frame(height: 180)
                            }
                        }

                        EditorialCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Mix of marks")
                                    .font(.system(.headline, design: .serif))
                                    .foregroundColor(Color("AppTextPrimary"))
                                Chart(mix) { slice in
                                    BarMark(
                                        x: .value("Count", slice.count),
                                        y: .value("Kind", slice.title)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color("AppPrimary"), Color("AppAccent")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                }
                                .chartXAxis {
                                    AxisMarks { _ in
                                        AxisGridLine().foregroundStyle(Color("AppPrimary").opacity(0.18))
                                        AxisValueLabel()
                                            .foregroundStyle(Color("AppTextSecondary"))
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { _ in
                                        AxisValueLabel()
                                            .foregroundStyle(Color("AppTextPrimary"))
                                    }
                                }
                                .frame(height: 140)
                            }
                        }

                        if tags.isEmpty == false {
                            EditorialCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Tags in play")
                                        .font(.system(.headline, design: .serif))
                                        .foregroundColor(Color("AppTextPrimary"))
                                    Chart(tags) { slice in
                                        BarMark(
                                            x: .value("Tag", slice.tag),
                                            y: .value("Uses", slice.count)
                                        )
                                        .foregroundStyle(Color("AppPrimary"))
                                    }
                                    .chartXAxis {
                                        AxisMarks { _ in
                                            AxisValueLabel()
                                                .foregroundStyle(Color("AppTextSecondary"))
                                        }
                                    }
                                    .chartYAxis {
                                        AxisMarks(position: .leading) { _ in
                                            AxisGridLine().foregroundStyle(Color("AppPrimary").opacity(0.18))
                                            AxisValueLabel()
                                                .foregroundStyle(Color("AppTextSecondary"))
                                        }
                                    }
                                    .frame(height: 160)
                                }
                            }
                        }
                    } else {
                        EditorialCard {
                            EmptyStateBlock(
                                symbol: "chart.bar",
                                message: "Compose a memo, caption a table, or heart a collection — the pulse will draw itself."
                            )
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
                    Text("Statistics")
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(Color("AppTextPrimary"))
                }
            }
            .tint(Color("AppPrimary"))
        }
        .screenBackground()
    }

    private func summaryTile(title: String, value: String) -> some View {
        EditorialCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color("AppTextSecondary"))
                Text(value)
                    .font(.system(.title, design: .serif))
                    .foregroundColor(Color("AppTextPrimary"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
