import SwiftUI
import Combine

struct MatchedEntry: Identifiable {
    let entry: DictionaryEntry
    let relevanceScore: Int

    var id: String { entry.id }
}

// Shared with FavoritesTab to track its parallax header offset.
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// A precomputed section keeps filtering and grouping work out of body rendering.
struct WordSection: Identifiable {
    let id: String          // section letter
    let items: [MatchedEntry]
}

struct HomeTab: View {
    static private var cachedEntries: [DictionaryEntry] = []
    static private var hasLoadedOnce = false

    @State private var selectedLanguage = "Kistanigna"
    @State private var searchText = ""
    @State private var isLoading = true
    @State private var fullEntries: [DictionaryEntry] = []
    @State private var selectedEntry: DictionaryEntry?
    @State private var showSearchBar = false

    // Search sections are rebuilt off the main thread when the query changes.
    @State private var sections: [WordSection] = []
    @State private var resultCount: Int = 0
    @State private var rebuildTask: Task<Void, Never>?

    @AppStorage("favoriteKeys") private var favoriteKeysRaw: String = ""
    @FocusState private var searchFieldFocused: Bool

    let languages = ["Kistanigna", "English", "Amharic"]
    private let bannerTimer = Timer.publish(every: 4.0, on: .main, in: .common).autoconnect()

    // MARK: - Favorites

    func getFavoriteKeys() -> [String] {
        FavoriteKeyStore.decode(favoriteKeysRaw)
    }

    func setFavoriteKeys(_ keys: [String]) {
        favoriteKeysRaw = FavoriteKeyStore.encode(keys)
    }

    func isFavorite(_ entry: DictionaryEntry) -> Bool {
        getFavoriteKeys().contains(entry.key)
    }

    func toggleFavorite(_ entry: DictionaryEntry) {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        var updated = getFavoriteKeys()
        if let index = updated.firstIndex(of: entry.key) {
            updated.remove(at: index)
        } else {
            updated.append(entry.key)
        }
        setFavoriteKeys(updated)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AnimatedGradientBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar          // pinned: title + search toggle + search field
                listContent     // scrolls: banner, picker, word sections
            }

            wordDetailOverlay
            loadingOverlay
        }
        .onAppear {
            loadEntries()
        }
        .onChange(of: searchText) { _ in
            scheduleRebuild(debounce: true)     // wait for typing to pause
        }
        .onChange(of: selectedLanguage) { _ in
            scheduleRebuild(debounce: false)    // instant on language switch
        }
        .onChange(of: fullEntries.count) { _ in
            scheduleRebuild(debounce: false)    // when full dictionary lands
        }
    }

    // ── Pinned top bar ───────────────────────────────────────

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Kistanigna Dictionary")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Spacer()

                Button {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()

                    withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                        showSearchBar.toggle()
                    }

                    if showSearchBar {
                        searchFieldFocused = true
                    } else {
                        searchText = ""
                        searchFieldFocused = false
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.8)
                            )

                        Image(systemName: showSearchBar ? "xmark" : "magnifyingglass")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(showSearchBar ? 90 : 0))
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSearchBar)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            if showSearchBar {
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))

                        TextField("Search words...", text: $searchText)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.white)
                            .accentColor(.white)
                            .focused($searchFieldFocused)
                            .autocorrectionDisabled(true)

                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8)
                            )
                    )

                    if !searchText.isEmpty {
                        HStack {
                            Text("\(resultCount) results")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.65))
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.bottom, 12)
    }

    // ── Scrolling content ────────────────────────────────────

    private var listContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 14, pinnedViews: [.sectionHeaders]) {

                // Banner + picker scroll away naturally — no padding hack,
                // no floating overlay, nothing to collide with.
                if searchText.isEmpty {
                    headerCarouselAndPicker
                        .transition(.opacity)
                } else {
                    // While searching, just the picker stays for quick switching
                    languagePicker
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                }

                ForEach(sections) { section in
                    Section(header: SectionHeaderView(title: section.id)) {
                        ForEach(section.items) { matched in
                            PremiumWordCard(
                                entry: matched.entry,
                                selectedLanguage: selectedLanguage,
                                displayText: displayText(for: matched.entry),
                                isFavorite: isFavorite(matched.entry),
                                onFavoriteToggle: { toggleFavorite(matched.entry) },
                                onTap: { selectedEntry = matched.entry },
                                animationDelay: 0
                            )
                        }
                    }
                }

                if sections.isEmpty && !searchText.isEmpty && !isLoading {
                    VStack(spacing: 10) {
                        Image(systemName: "text.magnifyingglass")
                            .font(.system(size: 30, weight: .light))
                            .foregroundColor(.white.opacity(0.4))

                        Text("No matches for \"\(searchText)\"")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }
            }
            .padding(.bottom, 120)
        }
        .refreshable {
            await refreshData()
        }
    }

    private var headerCarouselAndPicker: some View {
        VStack(spacing: 18) {
            BannerCarousel(timer: bannerTimer)

            languagePicker
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
        .padding(.bottom, 6)
    }

    private var languagePicker: some View {
        LanguagePickerBar(
            languages: languages,
            selectedLanguage: $selectedLanguage
        )
    }

    // MARK: - Overlays

    @ViewBuilder
    private var wordDetailOverlay: some View {
        if let entry = selectedEntry {
            PremiumWordDetailOverlay(
                entry: entry,
                selectedLanguage: selectedLanguage,
                displayText: displayText(for: entry),
                isFavorite: isFavorite(entry),
                onFavoriteToggle: { toggleFavorite(entry) },
                onClose: { selectedEntry = nil }
            )
            .transition(.asymmetric(
                insertion: .scale(scale: 0.85).combined(with: .opacity),
                removal: .scale(scale: 0.9).combined(with: .opacity)
            ))
            .zIndex(10)
        }
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if isLoading {
            PremiumLoadingOverlay()
        }
    }

    // MARK: - Display helpers

    func displayText(for entry: DictionaryEntry) -> String {
        switch selectedLanguage {
        case "English": return entry.english
        case "Amharic": return entry.amharic
        default: return entry.word
        }
    }

    // ─────────────────────────────────────────────────────────
    //  THE SPEED FIX
    //  Scoring + sorting + grouping of ~10k entries now runs
    //  in a background task, debounced while typing, and lands
    //  as ready-made sections. The main thread only renders.
    // ─────────────────────────────────────────────────────────

    private func scheduleRebuild(debounce: Bool) {
        rebuildTask?.cancel()

        // Capture everything the background work needs as plain values
        let entriesSnapshot = fullEntries
        let query = searchText
        let language = selectedLanguage

        rebuildTask = Task {
            if debounce {
                try? await Task.sleep(nanoseconds: 200_000_000)  // 0.2s after last keystroke
                if Task.isCancelled { return }
            }

            let built = Self.buildSections(
                entries: entriesSnapshot,
                query: query,
                language: language
            )
            if Task.isCancelled { return }

            await MainActor.run {
                withAnimation(.easeOut(duration: 0.18)) {
                    self.sections = built.sections
                    self.resultCount = built.count
                }
            }
        }
    }

    // Pure function — no self, safe off the main thread
    static func buildSections(
        entries: [DictionaryEntry],
        query: String,
        language: String
    ) -> (sections: [WordSection], count: Int) {

        let normalizedQuery = normalizedSearchText(query)

        func display(_ entry: DictionaryEntry) -> String {
            switch language {
            case "English": return entry.english
            case "Amharic": return entry.amharic
            default: return entry.word
            }
        }

        // Rank exact and prefix matches above general substring matches.
        let matched: [MatchedEntry]
        if normalizedQuery.isEmpty {
            matched = entries.map { MatchedEntry(entry: $0, relevanceScore: 0) }
        } else {
            matched = entries.compactMap { entry in
                let score = relevanceScore(entry: entry, query: normalizedQuery, language: language)
                return score > 0 ? MatchedEntry(entry: entry, relevanceScore: score) : nil
            }
            .sorted { first, second in
                if first.relevanceScore != second.relevanceScore {
                    return first.relevanceScore > second.relevanceScore
                }
                return display(first.entry) < display(second.entry)
            }
        }

        // Group ranked results by the first displayed character.
        var grouped: [String: [MatchedEntry]] = [:]
        for m in matched {
            let text = display(m.entry).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty, let first = text.first, first.isLetter else {
                grouped["#", default: []].append(m)
                continue
            }
            grouped[String(first).uppercased(), default: []].append(m)
        }

        // Present section headers in a stable alphabetical order.
        let letterKeys = grouped.keys.filter {
            $0 != "#" && $0.range(of: "^[A-Za-zሀ-፿]", options: .regularExpression) != nil
        }.sorted()
        let otherKeys = grouped.keys.filter { !letterKeys.contains($0) }.sorted()
        let orderedKeys = letterKeys + otherKeys

        // While searching, keep relevance order inside one flat section
        if !normalizedQuery.isEmpty {
            guard !matched.isEmpty else { return ([], 0) }
            return ([WordSection(id: "Results", items: matched)], matched.count)
        }

        let sections = orderedKeys.map { key in
            WordSection(id: key, items: grouped[key] ?? [])
        }
        return (sections, matched.count)
    }

    // Your original scoring — now a static pure function
    static func relevanceScore(entry: DictionaryEntry, query: String, language: String) -> Int {
        let normalizedQuery = normalizedSearchText(query)
        guard !normalizedQuery.isEmpty else { return 0 }

        let word = normalizedSearchText(entry.word)
        let english = normalizedSearchText(entry.english)
        let amharic = normalizedSearchText(entry.amharic)

        var score = 0

        guard word.contains(normalizedQuery) || english.contains(normalizedQuery) || amharic.contains(normalizedQuery) else {
            return 0
        }
        score = 10

        if word == normalizedQuery || english == normalizedQuery || amharic == normalizedQuery {
            score += 100
        }

        if word.hasPrefix(normalizedQuery) || english.hasPrefix(normalizedQuery) || amharic.hasPrefix(normalizedQuery) {
            score += 50
        }

        if word.count <= 5 || english.count <= 5 {
            score += 15
        }

        switch language {
        case "English":
            if english.contains(normalizedQuery) { score += 20 }
        case "Amharic":
            if amharic.contains(normalizedQuery) { score += 20 }
        default:
            if word.contains(normalizedQuery) { score += 20 }
        }

        return score
    }

    static func normalizedSearchText(_ text: String) -> String {
        // Search should behave the same regardless of the device's language settings.
        let searchLocale = Locale(identifier: "en_US_POSIX")
        return text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: searchLocale)
    }

    // MARK: - Loading

    func loadEntries() {
        if !Self.cachedEntries.isEmpty {
            self.fullEntries = Self.cachedEntries
            self.isLoading = false
            scheduleRebuild(debounce: false)
            return
        }

        if !Self.hasLoadedOnce {
            isLoading = true
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let preview = DictionaryLoader.loadPreview(limit: 50)
            DispatchQueue.main.async {
                self.fullEntries = preview
                if !Self.hasLoadedOnce {
                    self.isLoading = false
                }
            }

            let full = DictionaryLoader.loadFull()
            DispatchQueue.main.async {
                Self.cachedEntries = full
                Self.hasLoadedOnce = true
                self.fullEntries = full
            }
        }
    }

    func refreshData() async {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        let full = await Task.detached(priority: .userInitiated) {
            DictionaryLoader.loadFull()
        }.value
        await MainActor.run {
            Self.cachedEntries = full
            self.fullEntries = full
        }
    }
}

// ─────────────────────────────────────────────────────────────
//  Banner carousel — timer is now a publisher (no leaked
//  Timer.scheduledTimer), swipes stay buttery
// ─────────────────────────────────────────────────────────────

struct BannerCarousel: View {
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    @State private var bannerIndex = 0

    var body: some View {
        VStack(spacing: 12) {
            TabView(selection: $bannerIndex) {
                ForEach(1..<4, id: \.self) { i in
                    Image("banner\(i)")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 260)
                        .clipped()
                        .tag(i - 1)
                }
            }
            .frame(height: 260)
            .cornerRadius(20)
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.3)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 14, x: 0, y: 8)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onReceive(timer) { _ in
                withAnimation(.easeInOut(duration: 1.2)) {
                    bannerIndex = (bannerIndex + 1) % 3
                }
            }

            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { index in
                    Capsule()
                        .fill(index == bannerIndex ? Color.white : Color.white.opacity(0.3))
                        .frame(width: index == bannerIndex ? 30 : 7, height: 7)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: bannerIndex)
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────
//  Language picker — same sliding-pill design, own view
// ─────────────────────────────────────────────────────────────

struct LanguagePickerBar: View {
    let languages: [String]
    @Binding var selectedLanguage: String
    @Namespace private var languageNamespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(languages, id: \.self) { language in
                Button {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        selectedLanguage = language
                    }
                } label: {
                    Text(language)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(selectedLanguage == language ? .black : .white)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity)
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
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 0.8)
                )
        )
    }
}

// ─────────────────────────────────────────────────────────────
// MARK: - Shared background
// ─────────────────────────────────────────────────────────────

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.2, blue: 0.1),
                Color(red: 0.2, green: 0.3, blue: 0.2),
                Color(red: 0.15, green: 0.25, blue: 0.15),
                Color(red: 0.1, green: 0.2, blue: 0.1)
            ]),
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}
