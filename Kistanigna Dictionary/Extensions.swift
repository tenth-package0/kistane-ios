import SwiftUI

enum FavoriteKeyStore {
    static func decode(_ rawValue: String) -> [String] {
        guard !rawValue.isEmpty else { return [] }

        if let data = rawValue.data(using: .utf8),
           let keys = try? JSONDecoder().decode([String].self, from: data) {
            return uniqueKeys(keys)
        }

        // Support values saved by versions that used comma-separated keys.
        return uniqueKeys(rawValue.split(separator: ",").map(String.init))
    }

    static func encode(_ keys: [String]) -> String {
        guard let data = try? JSONEncoder().encode(uniqueKeys(keys)),
              let value = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return value
    }

    private static func uniqueKeys(_ keys: [String]) -> [String] {
        var seen = Set<String>()
        return keys.filter { seen.insert($0).inserted }
    }
}

extension Animation {
    static func spring(response: Double, dampingFraction: Double) -> Animation {
        .spring(response: response, dampingFraction: dampingFraction, blendDuration: 0)
    }
}

func combinedTransition(insertion: AnyTransition, removal: AnyTransition) -> AnyTransition {
    .asymmetric(insertion: insertion, removal: removal)
}

func scaleTransition(scale: CGFloat) -> AnyTransition {
    .scale(scale: scale)
}
