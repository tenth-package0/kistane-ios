import Foundation

struct DictionaryEntry: Codable, Identifiable {
    let word: String
    let english: String
    let amharic: String
    let definition: String

    var id: String { key }

    var key: String {
        "\(word)-\(english)-\(amharic)"
    }

    private enum CodingKeys: String, CodingKey {
        case word, english, amharic, definition
    }
}
