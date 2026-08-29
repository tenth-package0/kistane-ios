import SwiftUI

struct QuizReviewItem: Identifiable {
    let id = UUID()
    let prompt: String
    let correct: String
    let selected: String?
}

// ─────────────────────────────────────────────────────────────
//  Quiz answer review
//  • Cards cascade in with a soft stagger
//  • Tinted outline status pills, hairline dividers
//  • Score summary strip at the top
// ─────────────────────────────────────────────────────────────

struct QuizReviewView: View {
    let reviewItems: [QuizReviewItem]
    @Environment(\.dismiss) private var dismiss
    @State private var animateIn = false

    private var correctCount: Int {
        reviewItems.filter { $0.selected == $0.correct }.count
    }

    var body: some View {
        ZStack {
            // Match the background used throughout the quiz flow.
            Color(red: 0.2, green: 0.3, blue: 0.2)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ──
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("REVIEW")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .kerning(3)
                            .foregroundColor(.white.opacity(0.5))

                        Text("Your Answers")
                            .font(.system(size: 26, weight: .bold, design: .serif))
                            .foregroundColor(.white)

                        Text("\(correctCount) of \(reviewItems.count) correct")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.55))
                            .padding(.top, 2)
                    }

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 34, height: 34)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8)
                                    )
                            )
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 24)
                .padding(.bottom, 18)

                // ── Cards ──
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(Array(reviewItems.enumerated()), id: \.element.id) { index, item in
                            ReviewCard(item: item, index: index + 1)
                                .opacity(animateIn ? 1 : 0)
                                .offset(y: animateIn ? 0 : 40)
                                .animation(
                                    .spring(response: 0.55, dampingFraction: 0.85)
                                    .delay(Double(index) * 0.07),
                                    value: animateIn
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            animateIn = true
        }
    }
}

struct ReviewCard: View {
    let item: QuizReviewItem
    let index: Int

    private var isCorrect: Bool {
        item.selected == item.correct
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("QUESTION \(index)")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .kerning(2)
                    .foregroundColor(.white.opacity(0.5))

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: isCorrect ? "checkmark" : "xmark")
                        .font(.system(size: 10, weight: .bold))
                    Text(isCorrect ? "Correct" : "Incorrect")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundColor(isCorrect ? .green : .red)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill((isCorrect ? Color.green : Color.red).opacity(0.15))
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    (isCorrect ? Color.green : Color.red).opacity(0.4),
                                    lineWidth: 0.8
                                )
                        )
                )
            }

            Text(item.prompt)
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(.white)

            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 0.8)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("Correct answer")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))

                    Text(item.correct)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.green)
                }

                if let selected = item.selected, selected != item.correct {
                    HStack(spacing: 8) {
                        Text("Your answer")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.55))

                        Text(selected)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.8)
                )
        )
    }
}
