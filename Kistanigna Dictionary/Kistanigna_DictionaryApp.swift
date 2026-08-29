import SwiftUI

@main
struct Kistanigna_DictionaryApp: App {
    @State private var showSplash = false // Start with false, let logic decide
    
    init() {
        // Search bar text color
        let textFieldAppearance = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        textFieldAppearance.defaultTextAttributes = [.foregroundColor: UIColor.white]
        
        // Beautiful tab bar styling
        let tabBarAppearance = UITabBarAppearance()
        
        // Create gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.1, green: 0.2, blue: 0.1, alpha: 0.95).cgColor,
            UIColor(red: 0.2, green: 0.3, blue: 0.2, alpha: 0.9).cgColor,
            UIColor(red: 0.15, green: 0.25, blue: 0.15, alpha: 0.95).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
        
        // Convert gradient to image
        UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: context)
        }
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Apply gradient background
        tabBarAppearance.backgroundImage = gradientImage
        tabBarAppearance.shadowColor = UIColor.black.withAlphaComponent(0.3)
        tabBarAppearance.shadowImage = UIImage()
        
        // Beautiful icon colors
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        
        // Add subtle glow effect to selected icons
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        // Apply the appearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Add blur effect
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundColor = UIColor.clear
    }
    
    private func checkShouldShowSplash() {
        let currentTime = Date().timeIntervalSince1970
        let openCount = UserDefaults.standard.integer(forKey: "appOpenCount")
        let lastSplashTime = UserDefaults.standard.double(forKey: "lastSplashTime")
        
        // Increment open count
        let newOpenCount = openCount + 1
        UserDefaults.standard.set(newOpenCount, forKey: "appOpenCount")
        UserDefaults.standard.set(currentTime, forKey: "lastAppOpenTime")
        
        var shouldShow = false
        
        // First time opening the app
        if openCount == 0 {
            shouldShow = true
            print("🎬 Splash: First time opening app")
        }
        // Every 2nd app open
        else if newOpenCount % 2 == 0 {
            shouldShow = true
            print("🎬 Splash: Every 2nd open (count: \(newOpenCount))")
        }
        // Or if 7+ hours have passed since last splash
        else if lastSplashTime > 0 {
            let sevenHoursInSeconds: Double = 7 * 60 * 60 // 7 hours
            let timeSinceLastSplash = currentTime - lastSplashTime
            
            if timeSinceLastSplash >= sevenHoursInSeconds {
                shouldShow = true
                print("🎬 Splash: 7+ hours passed (\(Int(timeSinceLastSplash/3600)) hours)")
            } else {
                print("⏰ Splash: Only \(Int(timeSinceLastSplash/3600)) hours since last splash")
            }
        }
        
        if shouldShow {
            showSplash = true
            UserDefaults.standard.set(currentTime, forKey: "lastSplashTime")
            print("✨ Showing splash screen!")
        } else {
            showSplash = false
            print("🚫 Skipping splash screen")
        }
        
        print("📊 Stats - Opens: \(newOpenCount), Last splash: \(Int((currentTime - lastSplashTime)/3600))h ago")
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
                    .transition(.opacity)
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .onAppear {
                // Check splash logic when app appears
                checkShouldShowSplash()
            }
        }
    }
}
