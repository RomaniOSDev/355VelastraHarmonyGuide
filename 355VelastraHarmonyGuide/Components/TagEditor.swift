import SwiftUI

struct TagEditor: View {
    @Binding var tags: [String]
    @Binding var draft: String
    let suggestions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                TextField("Add a tag", text: $draft)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .foregroundColor(Color("AppTextPrimary"))
                    .submitLabel(.done)
                    .onSubmit(addDraft)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color("AppBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                Button(action: addDraft) {
                    Image(systemName: "plus")
                        .font(.body.weight(.semibold))
                        .foregroundColor(Color("AppTextPrimary"))
                        .padding(10)
                        .background(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            if !tags.isEmpty {
                FlowChips(items: tags, onRemove: remove)
            }

            if !visibleSuggestions.isEmpty {
                Text("Suggested")
                    .font(.caption)
                    .foregroundColor(Color("AppTextSecondary"))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(visibleSuggestions, id: \.self) { tag in
                            Button {
                                append(tag)
                            } label: {
                                Text(tag)
                                    .font(.caption)
                                    .foregroundColor(Color("AppTextPrimary"))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
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
                }
            }
        }
    }

    private var visibleSuggestions: [String] {
        suggestions.filter { suggestion in
            !tags.contains(where: { $0.caseInsensitiveCompare(suggestion) == .orderedSame })
        }
    }

    private func addDraft() {
        append(draft)
        draft = ""
    }

    private func append(_ raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if tags.contains(where: { $0.caseInsensitiveCompare(trimmed) == .orderedSame }) {
            return
        }
        tags.append(trimmed)
    }

    private func remove(_ tag: String) {
        tags.removeAll { $0.caseInsensitiveCompare(tag) == .orderedSame }
    }
}

private struct FlowChips: View {
    let items: [String]
    let onRemove: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { tag in
                        HStack(spacing: 6) {
                            Text(tag)
                                .font(.caption)
                                .foregroundColor(Color("AppTextPrimary"))
                            Button {
                                onRemove(tag)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(Color("AppTextSecondary"))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color("AppBackground"))
                        .overlay(
                            Capsule()
                                .stroke(Color("AppPrimary"), lineWidth: 1)
                        )
                        .clipShape(Capsule())
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var rows: [[String]] {
        var result: [[String]] = []
        var current: [String] = []
        var budget = 0
        for item in items {
            let cost = item.count + 2
            if !current.isEmpty && budget + cost > 28 {
                result.append(current)
                current = [item]
                budget = cost
            } else {
                current.append(item)
                budget += cost
            }
        }
        if !current.isEmpty {
            result.append(current)
        }
        return result
    }
}
