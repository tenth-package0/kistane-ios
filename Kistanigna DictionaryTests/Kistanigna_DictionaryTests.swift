import Foundation
import Testing
@testable import SG_Dictionary

struct Kistanigna_DictionaryTests {

    @Test func decodesDictionaryEntry() throws {
        let json = #"{"word":"ሰላም","english":"hello","amharic":"ሰላም","definition":"A greeting"}"#
        let entry = try JSONDecoder().decode(DictionaryEntry.self, from: Data(json.utf8))

        #expect(entry.word == "ሰላም")
        #expect(entry.english == "hello")
        #expect(entry.amharic == "ሰላም")
        #expect(entry.definition == "A greeting")
    }

    @Test func favoriteKeysRoundTripThroughStorage() {
        let keys = ["ሰላም-hello-ሰላም", "አበባ-flower-አበባ"]

        #expect(FavoriteKeyStore.decode(FavoriteKeyStore.encode(keys)) == keys)
    }

    @Test func readsLegacyCommaSeparatedFavoriteKeys() {
        #expect(FavoriteKeyStore.decode("first,second") == ["first", "second"])
    }

    @Test func trimsLegacyFavoriteKeys() {
        #expect(FavoriteKeyStore.decode(" first, second , ") == ["first", "second"])
    }

    @Test func dictionaryEntryIdentityIsStableAcrossDecodes() throws {
        let json = #"{"word":"ሰላም","english":"hello","amharic":"ሰላም","definition":"A greeting"}"#
        let data = Data(json.utf8)

        let first = try JSONDecoder().decode(DictionaryEntry.self, from: data)
        let second = try JSONDecoder().decode(DictionaryEntry.self, from: data)

        #expect(first.id == second.id)
    }

    @Test func favoriteStorageRemovesDuplicatesWithoutReordering() {
        let keys = ["first", "second", "first"]

        #expect(FavoriteKeyStore.decode(FavoriteKeyStore.encode(keys)) == ["first", "second"])
    }

    @Test func searchIgnoresWhitespaceCaseAndDiacritics() {
        let entry = DictionaryEntry(
            word: "ጤና",
            english: "Café",
            amharic: "ጤና",
            definition: "Example"
        )

        let result = HomeTab.buildSections(
            entries: [entry],
            query: "  CAFE  ",
            language: "English"
        )

        #expect(result.count == 1)
        #expect(result.sections.first?.items.first?.entry.id == entry.id)
    }

    @Test func searchNormalizationDoesNotDependOnDeviceLocale() {
        #expect(HomeTab.normalizedSearchText("  CAFÉ  ") == "cafe")
    }

    @Test func exactSearchRanksAheadOfPrefixAndSubstringMatches() {
        let exact = DictionaryEntry(word: "one", english: "art", amharic: "አንድ", definition: "Exact")
        let prefix = DictionaryEntry(word: "two", english: "artist", amharic: "ሁለት", definition: "Prefix")
        let substring = DictionaryEntry(word: "three", english: "cart", amharic: "ሶስት", definition: "Substring")

        let result = HomeTab.buildSections(
            entries: [substring, prefix, exact],
            query: "art",
            language: "English"
        )

        #expect(result.sections.first?.items.map(\.entry.id) == [exact.id, prefix.id, substring.id])
    }

    @Test func searchWithNoMatchesReturnsNoSections() {
        let entry = DictionaryEntry(
            word: "ሰላም",
            english: "hello",
            amharic: "ሰላም",
            definition: "A greeting"
        )

        let result = HomeTab.buildSections(
            entries: [entry],
            query: "goodbye",
            language: "English"
        )

        #expect(result.count == 0)
        #expect(result.sections.isEmpty)
    }

    @Test func quizRemovesDuplicateAndBlankAnswerWords() {
        let entries = [
            DictionaryEntry(word: "one", english: "first", amharic: "አንድ", definition: ""),
            DictionaryEntry(word: "one", english: "duplicate", amharic: "አንድ", definition: ""),
            DictionaryEntry(word: "  ", english: "blank", amharic: "", definition: ""),
            DictionaryEntry(word: "two", english: "second", amharic: "ሁለት", definition: "")
        ]

        #expect(QuizTab.uniqueEntriesByWord(entries).map(\.word) == ["one", "two"])
    }

    @Test func quizFallsBackWhenCategoryCannotBuildAQuestion() {
        let entries = [
            DictionaryEntry(word: "one", english: "hello", amharic: "አንድ", definition: ""),
            DictionaryEntry(word: "two", english: "second", amharic: "ሁለት", definition: ""),
            DictionaryEntry(word: "three", english: "third", amharic: "ሶስት", definition: ""),
            DictionaryEntry(word: "four", english: "fourth", amharic: "አራት", definition: "")
        ]
        let quiz = QuizTab(selectedCategory: "Greetings", onBack: {})

        #expect(quiz.filterEntriesByCategory(from: entries).count == 4)
    }

    @Test func quizCategoryMatchingUsesWholeWords() {
        let cat = DictionaryEntry(word: "one", english: "cat", amharic: "", definition: "")
        let catastrophe = DictionaryEntry(word: "two", english: "catastrophe", amharic: "", definition: "")

        #expect(QuizTab.englishTokens(in: cat).contains("cat"))
        #expect(!QuizTab.englishTokens(in: catastrophe).contains("cat"))
    }

    @Test func favoriteLookupReturnsOnlySavedEntries() {
        let saved = DictionaryEntry(word: "one", english: "first", amharic: "አንድ", definition: "")
        let unsaved = DictionaryEntry(word: "two", english: "second", amharic: "ሁለት", definition: "")

        let result = FavoritesTab.savedEntries(from: [saved, unsaved], keys: [saved.key])

        #expect(result.map(\.id) == [saved.id])
    }

    @Test func favoriteSearchIgnoresWhitespaceCaseAndDiacritics() {
        let entry = DictionaryEntry(word: "ጤና", english: "Café", amharic: "ጤና", definition: "")

        #expect(FavoritesTab.matchesSearch(entry, query: "  CAFE  "))
    }

}
