import Foundation

enum DictionaryLoader {
    private static let resourceName = "kistanigna_trilingual_dictionary_FIXED"

    private static func loadEntries() -> [DictionaryEntry] {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([DictionaryEntry].self, from: data) else {
            return []
        }
        return entries
    }

    static func loadPreview(limit: Int = 50) -> [DictionaryEntry] {
        Array(loadEntries().prefix(max(0, limit)))
    }

    static func loadFull() -> [DictionaryEntry] {
        loadEntries()
    }
}
