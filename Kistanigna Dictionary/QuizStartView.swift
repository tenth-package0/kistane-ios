import SwiftUI

struct QuizCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let color: Color
}

// ─────────────────────────────────────────────────────────────
//  Quiz category selection
//  • Ambient drifting glow orbs behind everything
//  • Shimmer sweep across the serif title
//  • Cards rise in with a soft cascade
//  • Icon rings "breathe" slowly
//  • Tap = instant launch (calls onSelect immediately)
// ─────────────────────────────────────────────────────────────

struct QuizStartView: View {
    var onSelect: (String) -> Void

    @State private var animateIn = false
    @State private var pressedCategory: String?

    let categories: [QuizCategory] = [
        QuizCategory(name: "Greetings", icon: "hand.wave", description: "Learn common greetings and introductions", color: Color.blue),
        QuizCategory(name: "Animals", icon: "pawprint", description: "Master animal names in Kistanigna", color: Color.orange),
        QuizCategory(name: "Food & Drink", icon: "fork.knife", description: "Explore culinary vocabulary", color: Color.green),
        QuizCategory(name: "Common Phrases", icon: "quote.bubble", description: "Essential phrases for daily conversation", color: Color.purple),
        QuizCategory(name: "Travel", icon: "airplane", description: "Useful words for getting around", color: Color.pink),
        QuizCategory(name: "Everyday Words", icon: "sun.max", description: "Build your basic vocabulary", color: Color.yellow),
        QuizCategory(name: "Random Mix", icon: "dice", description: "Test yourself on a variety of words", color: Color.red)
    ]

    var body: some View {
        ZStack {
            // Keep the category artwork within the app's green theme.
            Color(red: 0.2, green: 0.3, blue: 0.2)
                .ignoresSafeArea()

            // Ambient drifting orbs
            AmbientOrbsView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Header ──
                VStack(spacing: 10) {
                    Text("QUIZ")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .kerning(5)
                        .foregroundColor(.white.opacity(0.45))
                        .padding(.top, 64)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 10)

                    ShimmerText(text: "Choose Your Path")
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 14)

                    Text("Test your Kistanigna knowledge")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))
                        .padding(.bottom, 26)
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 14)
                }
                .padding(.horizontal, 20)
                .animation(.easeOut(duration: 0.7), value: animateIn)

                // ── Category cards ──
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                            LuxuryCategoryCard(
                                category: category,
                                isPressed: pressedCategory == category.name,
                                onPressChanged: { pressing in
                                    withAnimation(.spring(response: 0.32, dampingFraction: 0.7)) {
                                        pressedCategory = pressing ? category.name : nil
                                    }
                                },
                                onSelect: {
                                    let impact = UIImpactFeedbackGenerator(style: .soft)
                                    impact.impactOccurred()
                                    // Fire IMMEDIATELY — no delay, no detour.
                                    onSelect(category.name)
                                }
                            )
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : 70)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.85)
                                .delay(0.08 + Double(index) * 0.07),
                                value: animateIn
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 120)
                }
            }
        }
        .onAppear {
            animateIn = true
        }
    }
}

// ─────────────────────────────────────────────────────────────
//  Category card
// ─────────────────────────────────────────────────────────────

struct LuxuryCategoryCard: View {
    let category: QuizCategory
    let isPressed: Bool
    let onPressChanged: (Bool) -> Void
    let onSelect: () -> Void

    @State private var breathe = false

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 18) {
                // Breathing icon ring
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.14))
                        .frame(width: 58, height: 58)

                    Circle()
                        .strokeBorder(category.color.opacity(breathe ? 0.65 : 0.35), lineWidth: 1)
                        .frame(width: 58, height: 58)
                        .scaleEffect(breathe ? 1.04 : 1.0)

                    Image(systemName: category.icon)
                        .font(.system(size: 21, weight: .light))
                        .foregroundColor(category.color)
                }
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: Double.random(in: 2.6...3.6))
                        .repeatForever(autoreverses: true)
                    ) {
                        breathe = true
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(category.name)
                        .font(.system(size: 19, weight: .semibold, design: .serif))
                        .foregroundColor(.white)

                    Text(category.description)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .offset(x: isPressed ? 4 : 0)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(isPressed ? 0.11 : 0.07))

                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.28),
                                    Color.white.opacity(0.04)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.22), radius: 18, x: 0, y: 10)
            .scaleEffect(isPressed ? 0.975 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                onPressChanged(pressing)
            },
            perform: {}
        )
    }
}

// ─────────────────────────────────────────────────────────────
//  Shimmer title — a slow light sweep across serif text
// ─────────────────────────────────────────────────────────────

struct ShimmerText: View {
    let text: String
    @State private var phase: CGFloat = -1.2

    var body: some View {
        Text(text)
            .font(.system(size: 34, weight: .bold, design: .serif))
            .foregroundColor(.white)
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color.white.opacity(0.55),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: geo.size.width * phase)
                    .blendMode(.screen)
                }
                .mask(
                    Text(text)
                        .font(.system(size: 34, weight: .bold, design: .serif))
                )
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.8)
                    .repeatForever(autoreverses: false)
                    .delay(0.6)
                ) {
                    phase = 1.4
                }
            }
    }
}

// ─────────────────────────────────────────────────────────────
//  Ambient orbs — slow drifting glows in theme tones
// ─────────────────────────────────────────────────────────────

struct AmbientOrbsView: View {
    @State private var drift = false

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 340, height: 340)
                .blur(radius: 70)
                .offset(x: drift ? -110 : -60, y: drift ? -240 : -190)

            Circle()
                .fill(Color(red: 0.3, green: 0.45, blue: 0.3).opacity(0.35))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: drift ? 140 : 100, y: drift ? 60 : 120)

            Circle()
                .fill(Color(red: 0.15, green: 0.22, blue: 0.15).opacity(0.5))
                .frame(width: 380, height: 380)
                .blur(radius: 90)
                .offset(x: drift ? -80 : -130, y: drift ? 330 : 280)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 9)
                .repeatForever(autoreverses: true)
            ) {
                drift = true
            }
        }
    }
}
