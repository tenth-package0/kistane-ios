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

}
