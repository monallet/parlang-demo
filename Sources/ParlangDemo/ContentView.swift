import SwiftUI

struct ContentView: View {
    @State private var selectedSection = DemoSection.lists
    @State private var query = ""
    @State private var selectedLanguageIDs: Set<String> = ["en", "de"]
    @State private var enabledFilters: Set<SearchFilter> = [.words, .meaning]

    var body: some View {
        NavigationSplitView {
            List(DemoSection.allCases, selection: $selectedSection) { section in
                Label(section.title, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationTitle("Parlang")
        } detail: {
            Group {
                switch selectedSection {
                case .menu:
                    MenuView(selectedLanguageIDs: $selectedLanguageIDs)
                case .lists:
                    ListsView(query: $query, selectedLanguageIDs: selectedLanguageIDs)
                case .mine:
                    MineView(book: DemoData.book)
                case .settings:
                    SettingsView(enabledFilters: $enabledFilters)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DemoColors.pageBackground)
        }
    }
}

private enum DemoSection: String, CaseIterable, Identifiable {
    case menu
    case lists
    case mine
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .menu: "Menu"
        case .lists: "Lists"
        case .mine: "Mine"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .menu: "sidebar.left"
        case .lists: "list.bullet.rectangle"
        case .mine: "person.text.rectangle"
        case .settings: "slider.horizontal.3"
        }
    }
}

private enum SearchFilter: String, CaseIterable, Identifiable {
    case words = "Words"
    case meaning = "Meaning"
    case examples = "Examples"
    case tags = "Tags"
    case categories = "Categories"

    var id: String { rawValue }
}

private struct MenuView: View {
    @Binding var selectedLanguageIDs: Set<String>

    var body: some View {
        DemoPage(title: "Menu", subtitle: "Select the languages shown in the vocabulary lists.") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ForEach(DemoData.languages) { language in
                    Button {
                        toggle(language.id)
                    } label: {
                        HStack {
                            Text(language.name)
                            Spacer()
                            Image(systemName: selectedLanguageIDs.contains(language.id) ? "checkmark.circle.fill" : "circle")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private func toggle(_ languageID: String) {
        if selectedLanguageIDs.contains(languageID) {
            selectedLanguageIDs.remove(languageID)
        } else {
            selectedLanguageIDs.insert(languageID)
        }
    }
}

private struct ListsView: View {
    @Binding var query: String
    let selectedLanguageIDs: Set<String>

    private var visibleEntries: [DemoEntry] {
        let selectedLanguages = Set(DemoData.languages.filter { selectedLanguageIDs.contains($0.id) }.map(\.name))
        let languageFiltered = DemoData.entries.filter { selectedLanguages.contains($0.language) }
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return languageFiltered
        }
        return languageFiltered.filter {
            $0.term.localizedCaseInsensitiveContains(query) ||
            $0.meaning.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        DemoPage(title: "Lists", subtitle: "A rough public preview of vocabulary browsing.") {
            TextField("Search words or meanings", text: $query)
                .textFieldStyle(.roundedBorder)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), spacing: 12)], spacing: 12) {
                ForEach(visibleEntries) { entry in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(entry.term)
                                .font(.title3.weight(.semibold))
                            Spacer()
                            Text(entry.level)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.thinMaterial)
                                .clipShape(Capsule())
                        }
                        Text(entry.language)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text(entry.meaning)
                            .font(.body)
                        HStack {
                            ForEach(entry.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.accentColor.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding()
                    .background(DemoColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
}

private struct MineView: View {
    let book: DemoBook

    var body: some View {
        DemoPage(title: "Mine", subtitle: "The private app uses study books to organize personal learning.") {
            VStack(alignment: .leading, spacing: 16) {
                Text(book.title)
                    .font(.title2.weight(.semibold))
                Text("A book represents one learning goal: target language, current level, preferred rhythm, and saved vocabulary collections.")
                    .foregroundStyle(.secondary)
                Divider()
                LabeledContent("Target language", value: book.targetLanguage)
                LabeledContent("Current level", value: book.level)
                LabeledContent("Weekly sessions", value: "\(book.weeklySessions)")
                LabeledContent("Session length", value: "\(book.minutesPerSession) minutes")
                Text("Personalised study sessions are part of the product direction, but this public demo intentionally keeps the details brief.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(DemoColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

private struct SettingsView: View {
    @Binding var enabledFilters: Set<SearchFilter>

    var body: some View {
        DemoPage(title: "Settings", subtitle: "Only search filters are active in this public demo.") {
            VStack(alignment: .leading, spacing: 16) {
                Text("Search filters")
                    .font(.headline)
                ForEach(SearchFilter.allCases) { filter in
                    Toggle(filter.rawValue, isOn: Binding(
                        get: { enabledFilters.contains(filter) },
                        set: { isEnabled in
                            if isEnabled {
                                enabledFilters.insert(filter)
                            } else {
                                enabledFilters.remove(filter)
                            }
                        }
                    ))
                }
            }
            .padding()
            .background(DemoColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 12) {
                Text("Other settings")
                    .font(.headline)
                Text("Placeholder")
                    .foregroundStyle(.secondary)
                Text("Placeholder")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(DemoColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

private struct DemoPage<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.largeTitle.weight(.semibold))
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                content
            }
            .padding(24)
            .frame(maxWidth: 960, alignment: .leading)
        }
    }
}

#Preview {
    ContentView()
}

private enum DemoColors {
    static let pageBackground = Color(red: 0.95, green: 0.94, blue: 0.91)
    static let cardBackground = Color(red: 1.0, green: 0.99, blue: 0.97)
}
