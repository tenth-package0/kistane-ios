import SwiftUI

struct SplashScreenView: View {
    @State private var logoScale: CGFloat = 0.3
    @State private var logoRotation: Double = 0
    @State private var logoOpacity: Double = 0
    @State private var particlesOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var gradientRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var showRings: Bool = false
    @State private var ringScale1: CGFloat = 0.5
    @State private var ringScale2: CGFloat = 0.3
    @State private var ringScale3: CGFloat = 0.1
    @State private var showParticles: Bool = false
    @State private var backgroundImageOpacity: Double = 0
    
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background image
            Image("image44")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .opacity(backgroundImageOpacity)
                .ignoresSafeArea()
            
            // Dark overlay to make animations pop - only at bottom
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.3),
                        Color.black.opacity(0.6)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: UIScreen.main.bounds.height * 0.4)
            }
            .ignoresSafeArea()
            .opacity(backgroundImageOpacity)
            
            // The animated overlay adds depth without obscuring the artwork.
            AnimatedSplashBackground(gradientRotation: gradientRotation)
                .ignoresSafeArea()
                .opacity(0.1) // Very subtle since we want to see the image
            
            // Floating particles
            if showParticles {
                ForEach(0..<15, id: \.self) { index in
                    FloatingParticle(index: index)
                }
                .opacity(particlesOpacity)
            }
            
            // Main content - moved to bottom
            VStack {
                Spacer()
                
                // Content container at bottom
                VStack(spacing: 30) {
                    // Animated rings around logo - smaller and positioned better
                    ZStack {
                        if showRings {
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.4),
                                            Color.clear
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .frame(width: 140, height: 140)
                                .scaleEffect(ringScale1)
                                .opacity(1 - ringScale1 + 0.4)
                            
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.3),
                                            Color.clear
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                                .frame(width: 110, height: 110)
                                .scaleEffect(ringScale2)
                                .opacity(1 - ringScale2 + 0.3)
                            
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.2),
                                            Color.clear
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                                .frame(width: 80, height: 80)
                                .scaleEffect(ringScale3)
                                .opacity(1 - ringScale3 + 0.2)
                        }
                        
                        // Enhanced glow effect - smaller
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.4),
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulseScale)
                            .opacity(logoOpacity)
                        
                        // App icon/logo - smaller
                        ZStack {
                            // Background circle with stronger shadow
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.95),
                                            Color.white.opacity(0.8)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
                                .shadow(color: Color.white.opacity(0.3), radius: 8, x: 0, y: -3)
                            
                            // Icon content - smaller
                            Text("ክ")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.1))
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                        .scaleEffect(logoScale)
                        .rotationEffect(.degrees(logoRotation))
                        .opacity(logoOpacity)
                    }
                    
                    // App name with enhanced premium styling - more compact
                    VStack(spacing: 8) {
                        Text("Kistanigna")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.6), radius: 12, x: 0, y: 6)
                            .shadow(color: Color.white.opacity(0.3), radius: 4, x: 0, y: -1)
                        
                        Text("Dictionary")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 4)
                        
                        Text("Trilingual Learning Experience")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 3)
                            .padding(.top, 4)
                    }
                    .opacity(textOpacity)
                    
                    // Enhanced loading indicator - smaller
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                .frame(width: 40, height: 40)
                            
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white,
                                            Color.white.opacity(0.4)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                )
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(gradientRotation))
                                .shadow(color: Color.white.opacity(0.5), radius: 8, x: 0, y: 0)
                        }
                        
                        Text("Welcome back")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(color: Color.black.opacity(0.5), radius: 6, x: 0, y: 3)
                    }
                    .opacity(textOpacity)
                }
                .padding(.bottom, 80) // Bottom padding to keep it off the very edge
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }
    
    private func startAnimationSequence() {
        // Start background image fade in
        withAnimation(.easeIn(duration: 0.8)) {
            backgroundImageOpacity = 1.0
        }
        
        // Start gradient rotation immediately
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            gradientRotation = 360
        }
        
        // Start loading spinner
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            gradientRotation = 360
        }
        
        // Sequence 1: Logo appears with scale and rotation (0.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 0.8)) {
                logoRotation = 360
            }
        }
        
        // Sequence 2: Pulse effect starts (0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.3
            }
        }
        
        // Sequence 3: Rings appear (1.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showRings = true
            withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                ringScale1 = 1.8
            }
            withAnimation(.easeOut(duration: 2.2).repeatForever(autoreverses: false).delay(0.2)) {
                ringScale2 = 2.0
            }
            withAnimation(.easeOut(duration: 2.4).repeatForever(autoreverses: false).delay(0.4)) {
                ringScale3 = 2.2
            }
        }
        
        // Sequence 4: Text appears (1.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                textOpacity = 1.0
            }
        }
        
        // Sequence 5: Particles appear (1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            showParticles = true
            withAnimation(.easeIn(duration: 1.0)) {
                particlesOpacity = 1.0
            }
        }
        
        // Complete after 3.5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                logoOpacity = 0
                textOpacity = 0
                particlesOpacity = 0
                backgroundImageOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onComplete()
            }
        }
    }
}

struct AnimatedSplashBackground: View {
    let gradientRotation: Double
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.1, blue: 0.05),
                    Color(red: 0.1, green: 0.2, blue: 0.1),
                    Color(red: 0.15, green: 0.25, blue: 0.15),
                    Color(red: 0.2, green: 0.3, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated overlay gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(0.1),
                    Color.clear,
                    Color.white.opacity(0.05),
                    Color.clear
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .rotationEffect(.degrees(gradientRotation))
            .animation(.linear(duration: 8).repeatForever(autoreverses: false), value: gradientRotation)
        }
    }
}

struct FloatingParticle: View {
    let index: Int
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.7))
            .frame(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5))
            .offset(x: xOffset, y: yOffset)
            .opacity(opacity)
            .scaleEffect(scale)
            .shadow(color: Color.white.opacity(0.4), radius: 4, x: 0, y: 0)
            .onAppear {
                let delay = Double(index) * 0.1
                let duration = Double.random(in: 4...7)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        opacity = Double.random(in: 0.3...0.7)
                        scale = 1.0
                    }
                    
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        yOffset = -UIScreen.main.bounds.height
                    }
                    
                    withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                        xOffset = CGFloat.random(in: -50...50)
                    }
                }
            }
            .position(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: UIScreen.main.bounds.height + 50
            )
    }
}
