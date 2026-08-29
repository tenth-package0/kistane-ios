
import SwiftUI

struct FavoritesView: View {
    // ✅ Match the same storage style as in ContentView
    @AppStorage("favoriteKeys") private var favoriteKeysRaw: String = ""
    var favoriteKeys: [String] {
        favoriteKeysRaw.components(separatedBy: ",").filter { !$0.isEmpty }
    }

    @State private var entries: [DictionaryEntry] = []

    var favoriteEntries: [DictionaryEntry] {
        entries.filter { favoriteKeys.contains($0.key) }
    }

    var body: some View {
        NavigationView {
            if favoriteEntries.isEmpty {
                VStack {
                    Spacer()
                    Text("No favorites yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .navigationTitle("Favorites")
            } else {
                List(favoriteEntries) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.word)
                            .font(.headline)

                        Text(entry.definition)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
                .navigationTitle("Favorites")
            }
        }
        .onAppear {
            entries = DictionaryLoader.loadFull()
        }
    }
}
