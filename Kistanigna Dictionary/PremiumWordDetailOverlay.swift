import SwiftUI

struct PremiumWordDetailOverlay: View {
    let entry: DictionaryEntry
    let selectedLanguage: String
    let displayText: String
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    let onClose: () -> Void
    
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            // Backdrop - tap anywhere to close
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    onClose()
                }
            
            // Content
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(displayText)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Word Details")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button(action: onFavoriteToggle) {
                            ZStack {
                                Circle()
                                    .fill(isFavorite ? Color.yellow.opacity(0.2) : Color.white.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: isFavorite ? "star.fill" : "star")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(isFavorite ? .yellow : .white.opacity(0.7))
                            }
                        }
                        .buttonStyle(PremiumButtonStyle())
                        
                        Button(action: onClose) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .buttonStyle(PremiumButtonStyle())
                    }
                }
                
                // Translations
                VStack(alignment: .leading, spacing: 16) {
                    if selectedLanguage != "Kistanigna" {
                        TranslationRow(label: "Kistanigna", value: entry.word, icon: "k.circle.fill")
                    }
                    
                    if selectedLanguage != "English" {
                        TranslationRow(label: "English", value: entry.english, icon: "e.circle.fill")
                    }
                    
                    if selectedLanguage != "Amharic" {
                        TranslationRow(label: "Amharic", value: entry.amharic, icon: "a.circle.fill")
                    }
                }
                
                // Definition
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "book.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Definition")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Text(entry.definition)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(6)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                }
                
                Spacer()
            }
            .padding(30)
            .frame(maxWidth: 500)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.2, green: 0.3, blue: 0.2),
                                    Color(red: 0.1, green: 0.2, blue: 0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                // Prevent tap-through to backdrop
            }
            .shadow(color: Color.black.opacity(0.5), radius: 30, x: 0, y: 15)
            .padding(30)
            .scaleEffect(animateContent ? 1.0 : 0.8)
            .opacity(animateContent ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateContent = true
                }
            }
        }
    }
}

struct TranslationRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
