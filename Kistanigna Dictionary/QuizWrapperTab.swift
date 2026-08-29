import SwiftUI

// ─────────────────────────────────────────────────────────────
//  THE BUG FIX LIVES HERE.
//
//  Before: selectedCategory was @State in ContentView, passed
//  down as a @Binding. Tapping a category mutated ContentView,
//  which re-rendered the whole tab structure and snapped you
//  back to the home tab.
//
//  Now: QuizWrapperTab OWNS the state. Tapping a category only
//  re-renders this view. ContentView never knows, the tab bar
//  never resets, and the quiz launches instantly.
//
//  ⚠️ ONE CHANGE NEEDED IN ContentView:
//     replace   QuizWrapperTab(selectedCategory: $selectedCategory)
//     with      QuizWrapperTab()
//     and delete the old @State var selectedCategory there.
// ─────────────────────────────────────────────────────────────

struct QuizWrapperTab: View {
    @State private var selectedCategory: String? = nil

    var body: some View {
        ZStack {
            if let category = selectedCategory {
                QuizTab(
                    selectedCategory: category,
                    onBack: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.88)) {
                            selectedCategory = nil
                        }
                    }
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    )
                )
                .zIndex(1)
            } else {
                QuizStartView(
                    onSelect: { name in
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.88)) {
                            selectedCategory = name
                        }
                    }
                )
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    )
                )
                .zIndex(0)
            }
        }
    }
}
