import Foundation

struct DictionaryEntry: Codable, Identifiable {
    let id: UUID = UUID()
    let word: String
    let english: String
    let amharic: String
    let definition: String

    var key: String {
        "\(word)-\(english)-\(amharic)"
    }

    private enum CodingKeys: String, CodingKey {
        case word, english, amharic, definition
    }
}
