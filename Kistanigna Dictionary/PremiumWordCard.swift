import SwiftUI

struct PremiumWordCard: View {
    let entry: DictionaryEntry
    let selectedLanguage: String
    let displayText: String
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    let onTap: () -> Void
    let animationDelay: Double
    
    @State private var isPressed = false
    @State private var showDefinition = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(displayText)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    VStack(alignment: .leading, spacing: 4) {
                        if selectedLanguage != "Kistanigna" {
                            Text(entry.word)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        if selectedLanguage != "English" {
                            Text(entry.english)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        if selectedLanguage != "Amharic" {
                            Text(entry.amharic)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    Button(action: onFavoriteToggle) {
                        ZStack {
                            Circle()
                                .fill(isFavorite ? Color.yellow.opacity(0.2) : Color.white.opacity(0.1))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(isFavorite ? .yellow : .white.opacity(0.7))
                                .scaleEffect(isFavorite ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFavorite)
                        }
                    }
                    .buttonStyle(PremiumButtonStyle())
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showDefinition.toggle()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: showDefinition ? "chevron.up" : "chevron.down")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.7))
                                .rotationEffect(.degrees(showDefinition ? 180 : 0))
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showDefinition)
                        }
                    }
                    .buttonStyle(PremiumButtonStyle())
                }
            }
            .padding(20)
            
            if showDefinition {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    Text("Definition")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(entry.definition)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                    removal: .scale(scale: 0.95).combined(with: .opacity)
                ))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
        .padding(.horizontal, 20)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
