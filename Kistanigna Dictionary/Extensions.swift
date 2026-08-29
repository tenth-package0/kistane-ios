import SwiftUI

extension Animation {
    static func spring(response: Double, dampingFraction: Double) -> Animation {
        return Animation.spring(response: response, dampingFraction: dampingFraction, blendDuration: 0)
    }
}

// Remove the problematic AnyTransition extensions
// Instead, provide helper functions that can be used directly

// Helper function for combined transitions
func combinedTransition(insertion: AnyTransition, removal: AnyTransition) -> AnyTransition {
    return AnyTransition.asymmetric(insertion: insertion, removal: removal)
}

// Helper function for scale transition
func scaleTransition(scale: CGFloat) -> AnyTransition {
    return AnyTransition.scale(scale: scale)
}

// Helper for conditional compilation
#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
// iOS-specific extensions can go here if needed
#endif
