import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Image(systemName: "house.fill")
                        .accessibilityLabel("Home")
                }

            FavoritesTab()
                .tabItem {
                    Image(systemName: "heart.fill")
                        .accessibilityLabel("Favorites")
                }

            TraditionsTab()
                .tabItem {
                    Image(systemName: "photo.fill")
                        .accessibilityLabel("Traditions")
                }

            QuizWrapperTab()
                .tabItem {
                    Image(systemName: "questionmark.circle.fill")
                        .accessibilityLabel("Quiz")
                }
        }
    }
}

#Preview {
    MainTabView()
}
