import Foundation

class DictionaryLoader {
    
    static func loadPreview(limit: Int = 50) -> [DictionaryEntry] {
        guard let url = Bundle.main.url(forResource: "kistanigna_trilingual_dictionary_FIXED", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let allEntries = try? JSONDecoder().decode([DictionaryEntry].self, from: data) else {
            print("❌ Failed to load preview")
            return []
        }

        print("✅ Preview loaded \(min(limit, allEntries.count)) of \(allEntries.count) entries")
        return Array(allEntries.prefix(limit))
    }

    static func loadFull() -> [DictionaryEntry] {
        guard let url = Bundle.main.url(forResource: "kistanigna_trilingual_dictionary_FIXED", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let entries = try? JSONDecoder().decode([DictionaryEntry].self, from: data) else {
            print("❌ Failed to load full dictionary")
            return []
        }

        print("✅ Loaded full dictionary with \(entries.count) entries")
        return entries
    }
}
