import Foundation

struct DemoLanguage: Identifiable, Hashable {
    let id: String
    let name: String
}

struct DemoEntry: Identifiable {
    let id = UUID()
    let term: String
    let language: String
    let meaning: String
    let level: String
    let tags: [String]
}

struct DemoBook {
    let title: String
    let targetLanguage: String
    let level: String
    let weeklySessions: Int
    let minutesPerSession: Int
}

enum DemoData {
    static let languages = [
        DemoLanguage(id: "en", name: "English"),
        DemoLanguage(id: "de", name: "German"),
        DemoLanguage(id: "fr", name: "French"),
        DemoLanguage(id: "es", name: "Spanish")
    ]

    static let entries = [
        DemoEntry(term: "journey", language: "English", meaning: "A trip from one place to another.", level: "A2", tags: ["travel", "daily"]),
        DemoEntry(term: "Reise", language: "German", meaning: "A journey or trip.", level: "A2", tags: ["travel", "noun"]),
        DemoEntry(term: "apprendre", language: "French", meaning: "To learn.", level: "A1", tags: ["study", "verb"]),
        DemoEntry(term: "recordar", language: "Spanish", meaning: "To remember.", level: "B1", tags: ["memory", "verb"])
    ]

    static let book = DemoBook(
        title: "Travel Foundations",
        targetLanguage: "German",
        level: "A2",
        weeklySessions: 3,
        minutesPerSession: 15
    )
}
