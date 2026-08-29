import SwiftUI

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
