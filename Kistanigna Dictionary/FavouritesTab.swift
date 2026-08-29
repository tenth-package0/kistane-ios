import SwiftUI

struct FavoritesTab: View {
    @AppStorage("favoriteKeys") private var favoriteKeysRaw: String = ""
    @State private var fullEntries: [DictionaryEntry] = []
    @State private var selectedLanguage = "Kistanigna"
    @State private var selectedEntry: DictionaryEntry? = nil
    @State private var isLoading = true
    @State private var animateCards = false
    @State private var searchText = ""
    @State private var showStats = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showFilterMenu = false
    @State private var selectedFilter: String? = nil
    @State private var isDeletionMode = false // New deletion mode state
    
    let languages = ["Kistanigna", "English", "Amharic"]
    let filterOptions = ["All", "Recently Added", "Alphabetical", "Most Viewed"]

    var favoriteEntries: [DictionaryEntry] {
        let keys = FavoriteKeyStore.decode(favoriteKeysRaw)
        var filtered = fullEntries.filter { keys.contains($0.key) }
        
        // Apply sorting based on filter
        if let filter = selectedFilter {
            switch filter {
            case "Alphabetical":
                filtered.sort { displayText(for: $0) < displayText(for: $1) }
            case "Recently Added":
                filtered = Array(filtered.reversed())
            default:
                break
            }
        }
        
        // Apply search filter if text exists
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            filtered = filtered.filter {
                $0.word.lowercased().contains(query) ||
                $0.english.lowercased().contains(query) ||
                $0.amharic.lowercased().contains(query)
            }
        }
        
        return filtered
    }

    var body: some View {
        ZStack {
            // Premium animated background
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            // Background tap detector for deletion mode
            if isDeletionMode {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        exitDeletionMode()
                    }
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                // Premium header with parallax effect
                premiumHeader
                    .offset(y: min(0, scrollOffset / 3))
                    .zIndex(1)
                
                if isLoading {
                    Spacer()
                    PremiumLoadingView()
                    Spacer()
                } else if favoriteEntries.isEmpty {
                    Spacer()
                    PremiumEmptyState(hasSearch: !searchText.isEmpty)
                    Spacer()
                } else {
                    // Content
                    ScrollView {
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollOffsetKey.self,
                                value: proxy.frame(in: .named("scrollView")).minY
                            )
                        }
                        .frame(height: 0)
                        
                        // Grid view
                        gridView
                            .padding(.bottom, 100)
                    }
                    .coordinateSpace(name: "scrollView")
                    .refreshable {
                        await refreshFavorites()
                    }
                    .onTapGesture {
                        if isDeletionMode {
                            exitDeletionMode()
                        }
                    }
                }
            }
            
            // Overlays
            ZStack {
                // Filter menu overlay
                if showFilterMenu {
                    filterMenuOverlay
                }
                
                // Word detail overlay (only show if not in deletion mode)
                if let entry = selectedEntry, !isDeletionMode {
                    PremiumWordDetailOverlay(
                        entry: entry,
                        selectedLanguage: selectedLanguage,
                        displayText: displayText(for: entry),
                        isFavorite: true,
                        onFavoriteToggle: {
                            removeFavorite(entry)
                            selectedEntry = nil
                        },
                        onClose: { selectedEntry = nil }
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                    .zIndex(1000)
                }
                
                // Stats overlay
                if showStats {
                    PremiumStatsOverlay(
                        favoriteCount: favoriteEntries.count,
                        onClose: { showStats = false }
                    )
                    .zIndex(999)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadFavorites()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateCards = true
            }
        }
        .onDisappear {
            animateCards = false
            isDeletionMode = false
        }
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            scrollOffset = value
        }
    }
    
    // MARK: - Header Views
    
    private var premiumHeader: some View {
        VStack(spacing: 16) {
            // Title and action buttons
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Favorites")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("\(favoriteEntries.count) words saved")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    // Done button when in deletion mode
                    if isDeletionMode {
                        Button(action: exitDeletionMode) {
                            Text("Done")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.2))
                                )
                        }
                        .buttonStyle(PremiumButtonStyle())
                    } else {
                        Button(action: { showStats = true }) {
                            premiumIconButton(icon: "chart.bar.fill")
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                showFilterMenu.toggle()
                            }
                        }) {
                            premiumIconButton(icon: "slider.horizontal.3")
                        }
                    }
                }
            }
            
            // Search bar (hide in deletion mode)
            if !isDeletionMode {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                    
                    TextField("Search favorites...", text: $searchText)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white)
                        .accentColor(.white)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Language picker (hide in deletion mode)
            if !isDeletionMode {
                HStack(spacing: 0) {
                    ForEach(languages, id: \.self) { language in
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selectedLanguage = language
                            }
                        }) {
                            Text(language)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(selectedLanguage == language ? .black : .white.opacity(0.8))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(
                                    ZStack {
                                        if selectedLanguage == language {
                                            Capsule()
                                                .fill(Color.white)
                                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                                                .matchedGeometryEffect(id: "languageSelector", in: languageNamespace)
                                        }
                                    }
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(4)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 16)
        .background(
            ZStack {
                // Glassmorphism effect
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.black.opacity(0.1))
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
            .blur(radius: 20)
            .ignoresSafeArea()
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isDeletionMode)
    }
    
    private func premiumIconButton(icon: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 44, height: 44)
            
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.8))
        }
        .buttonStyle(PremiumButtonStyle())
    }
    
    // MARK: - Content Views
    
    private var gridView: some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 160, maximum: 200), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(Array(favoriteEntries.enumerated()), id: \.element.id) { index, entry in
                IOSStyleFavoriteCard(
                    entry: entry,
                    selectedLanguage: selectedLanguage,
                    displayText: displayText(for: entry),
                    index: index,
                    isDeletionMode: isDeletionMode,
                    onTap: {
                        if !isDeletionMode {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            selectedEntry = entry
                        }
                    },
                    onLongPress: {
                        enterDeletionMode()
                    },
                    onDelete: {
                        deleteEntry(entry)
                    }
                )
                .scaleEffect(animateCards ? 1.0 : 0.8)
                .opacity(animateCards ? 1.0 : 0.0)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.8)
                    .delay(Double(index) * 0.05),
                    value: animateCards
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Filter Menu Overlay
    
    private var filterMenuOverlay: some View {
        ZStack {
            // Backdrop - tap anywhere to close
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showFilterMenu = false
                    }
                }
            
            // Menu
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Filter Favorites")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            showFilterMenu = false
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Filter options
                VStack(spacing: 8) {
                    ForEach(filterOptions, id: \.self) { option in
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                selectedFilter = option == "All" ? nil : option
                                showFilterMenu = false
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if (option == "All" && selectedFilter == nil) || selectedFilter == option {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill((option == "All" && selectedFilter == nil) || selectedFilter == option ?
                                          Color.white.opacity(0.2) : Color.clear)
                            )
                        }
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .frame(maxWidth: 320)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .transition(.scale(scale: 0.8).combined(with: .opacity))
        }
    }

    // MARK: - Deletion Mode Functions
    
    func enterDeletionMode() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isDeletionMode = true
        }
    }
    
    func exitDeletionMode() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            isDeletionMode = false
        }
    }
    
    func deleteEntry(_ entry: DictionaryEntry) {
        let impactFeedback = UINotificationFeedbackGenerator()
        impactFeedback.notificationOccurred(.success)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            removeFromFavorites(entry)
        }
    }

    // MARK: - Helper Functions
    
    func displayText(for entry: DictionaryEntry) -> String {
        switch selectedLanguage {
        case "English":
            return entry.english.isEmpty ? entry.word : entry.english
        case "Amharic":
            return entry.amharic.isEmpty ? entry.word : entry.amharic
        default:
            return entry.word
        }
    }
    
    func loadFavorites() {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let entries = DictionaryLoader.loadFull()
            DispatchQueue.main.async {
                self.fullEntries = entries
                self.isLoading = false
            }
        }
    }
    
    func refreshFavorites() async {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        DispatchQueue.main.async {
            self.fullEntries = DictionaryLoader.loadFull()
        }
    }
    
    func removeFavorite(_ entry: DictionaryEntry) {
        removeFromFavorites(entry)
        selectedEntry = nil
    }
    
    func removeFromFavorites(_ entry: DictionaryEntry) {
        var keys = FavoriteKeyStore.decode(favoriteKeysRaw)
        if let index = keys.firstIndex(of: entry.key) {
            keys.remove(at: index)
            favoriteKeysRaw = FavoriteKeyStore.encode(keys)
        }
    }
    
    @Namespace private var languageNamespace
}

// MARK: - Beautiful iOS Style Card with Premium Design

struct IOSStyleFavoriteCard: View {
    let entry: DictionaryEntry
    let selectedLanguage: String
    let displayText: String
    let index: Int
    let isDeletionMode: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    @State private var jiggleOffset: CGFloat = 0
    @State private var jiggleRotation: Double = 0
    
    var body: some View {
        ZStack {
            // Main beautiful card
            VStack(alignment: .leading, spacing: 16) {
                // Header with main word
                VStack(alignment: .leading, spacing: 8) {
                    Text(displayText)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Language indicator
                    Text(selectedLanguage)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                        )
                }
                
                // Beautiful translation section
                VStack(alignment: .leading, spacing: 10) {
                    if selectedLanguage != "Kistanigna" {
                        BeautifulTranslationRow(
                            label: "Kistanigna",
                            text: entry.word,
                            color: .blue
                        )
                    }
                    
                    if selectedLanguage != "English" {
                        BeautifulTranslationRow(
                            label: "English",
                            text: entry.english,
                            color: .green
                        )
                    }
                    
                    if selectedLanguage != "Amharic" {
                        BeautifulTranslationRow(
                            label: "Amharic",
                            text: entry.amharic,
                            color: .orange
                        )
                    }
                }
                
                Spacer()
                
                // Bottom accent line
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 40, height: 4)
                    Spacer()
                }
            }
            .padding(20)
            .frame(height: 200)
            .background(
                ZStack {
                    // Beautiful gradient background
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(isPressed ? 0.25 : 0.2),
                                    Color.white.opacity(isPressed ? 0.15 : 0.1),
                                    Color.white.opacity(isPressed ? 0.1 : 0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Beautiful border
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                    
                    // Subtle inner glow
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                }
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: Color.black.opacity(0.3), radius: isPressed ? 20 : 15, x: 0, y: isPressed ? 10 : 8)
            .shadow(color: Color.white.opacity(0.1), radius: 1, x: 0, y: 1) // Inner highlight
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isPressed)
            
            // Premium delete button (iOS style)
            if isDeletionMode {
                VStack {
                    HStack {
                        Button(action: onDelete) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 28, height: 28)
                                    .shadow(color: Color.red.opacity(0.5), radius: 4, x: 0, y: 2)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 28, height: 28)
                                
                                Image(systemName: "minus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .offset(x: -10, y: -10)
                        .scaleEffect(1.1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isDeletionMode)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .offset(x: isDeletionMode ? jiggleOffset : 0)
        .rotationEffect(.degrees(isDeletionMode ? jiggleRotation : 0))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isDeletionMode)
        .onAppear {
            if isDeletionMode {
                startJiggling()
            }
        }
        .onChange(of: isDeletionMode) { newValue in
            if newValue {
                startJiggling()
            } else {
                stopJiggling()
            }
        }
        .onTapGesture {
            onTap()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            onLongPress()
        } onPressingChanged: { pressing in
            if !isDeletionMode {
                isPressed = pressing
            }
        }
    }
    
    private func startJiggling() {
        let randomDelay = Double.random(in: 0...0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) {
            withAnimation(.easeInOut(duration: 0.15).repeatForever(autoreverses: true)) {
                jiggleOffset = Double.random(in: -2...2)
                jiggleRotation = Double.random(in: -1...1)
            }
        }
    }
    
    private func stopJiggling() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            jiggleOffset = 0
            jiggleRotation = 0
        }
    }
}

struct BeautifulTranslationRow: View {
    let label: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Beautiful colored indicator
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Circle()
                    .stroke(color.opacity(0.5), lineWidth: 1)
                    .frame(width: 24, height: 24)
                
                Text(String(label.prefix(1)))
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                
                Text(text)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// Keep the existing helper views (TranslationText, PremiumEmptyState, etc.)
struct TranslationText: View {
    let label: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 16, height: 16)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.1))
                )
            
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(1)
        }
    }
}

struct PremiumEmptyState: View {
    let hasSearch: Bool
    @State private var animateIcon = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: hasSearch ? "magnifyingglass" : "heart.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.4))
                    .scaleEffect(animateIcon ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateIcon)
            }
            
            VStack(spacing: 12) {
                Text(hasSearch ? "No matches found" : "No favorites yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(hasSearch ? "Try adjusting your search terms" : "Tap the star icon on any word to add it to your favorites")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .onAppear {
            animateIcon = true
        }
    }
}

struct PremiumLoadingView: View {
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color.white.opacity(0.3)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(rotationAngle))
                    .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: rotationAngle)
            }
            .scaleEffect(pulseScale)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseScale)
            
            Text("Loading favorites...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
        }
        .onAppear {
            rotationAngle = 360
            pulseScale = 1.2
        }
    }
}

struct PremiumStatsOverlay: View {
    let favoriteCount: Int
    let onClose: () -> Void
    @State private var animateContent = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    onClose()
                }
            
            VStack(spacing: 24) {
                HStack {
                    Text("Statistics")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: onClose) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .buttonStyle(PremiumButtonStyle())
                }
                
                VStack(spacing: 20) {
                    StatCard(
                        title: "Total Favorites",
                        value: "\(favoriteCount)",
                        icon: "heart.fill",
                        color: .red
                    )
                    
                    StatCard(
                        title: "Learning Progress",
                        value: "\(min(100, favoriteCount * 2))%",
                        icon: "chart.line.uptrend.xyaxis",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Words Mastered",
                        value: "\(favoriteCount / 3)",
                        icon: "star.fill",
                        color: .yellow
                    )
                }
                
                Spacer()
            }
            .padding(30)
            .frame(maxWidth: 400)
            .background(
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}
