import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Image(systemName: "house.fill")
                }

            FavoritesTab()
                .tabItem {
                    Image(systemName: "heart.fill")
                }

            TraditionsTab()
                .tabItem {
                    Image(systemName: "photo.fill")
                }

            QuizWrapperTab()
                .tabItem {
                    Image(systemName: "questionmark.circle.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
