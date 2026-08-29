import SwiftUI

enum FavoriteKeyStore {
    static func decode(_ rawValue: String) -> [String] {
        guard !rawValue.isEmpty else { return [] }

        if let data = rawValue.data(using: .utf8),
           let keys = try? JSONDecoder().decode([String].self, from: data) {
            return keys
        }

        // Support values saved by versions that used comma-separated keys.
        return rawValue.split(separator: ",").map(String.init)
    }

    static func encode(_ keys: [String]) -> String {
        guard let data = try? JSONEncoder().encode(keys),
              let value = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        return value
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
