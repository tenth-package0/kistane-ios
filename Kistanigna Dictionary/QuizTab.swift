import SwiftUI

// ─────────────────────────────────────────────────────────────
//  QUIZ — quiet luxury edition
//  • Questions slide in/out with eased cross-transitions
//  • Answer buttons resolve with soft color + dim the rest
//  • Animated hairline progress bar
//  • Results: glowing ring, count-up score, confetti burst
//  • No NavigationView (it caused the navigation weirdness)
//  • All quiz logic is YOUR original logic, untouched
// ─────────────────────────────────────────────────────────────

struct QuizTab: View {
    var selectedCategory: String
    var onBack: () -> Void

    @State private var entries: [DictionaryEntry] = []
    @State private var question: DictionaryEntry?
    @State private var promptText: String = ""
    @State private var options: [String] = []
    @State private var correctAnswer: String = ""
    @State private var answerSelected: String? = nil
    @State private var score = 0
    @State private var questionCount = 0
    @State private var quizFinished = false
    @State private var reviewItems: [QuizReviewItem] = []
    @State private var showReview = false

    // Animation state
    @State private var questionID = 0          // forces fresh transition per question
    @State private var animateRing = false
    @State private var displayedScore = 0      // count-up number
    @State private var showConfetti = false

    let totalQuestions = 7
    private let themeGreen = Color(red: 0.2, green: 0.3, blue: 0.2)

    var body: some View {
        ZStack {
            themeGreen
                .ignoresSafeArea()

            AmbientOrbsView()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                topBar

                if quizFinished {
                    resultsView
                        .transition(.opacity.combined(with: .scale(scale: 0.94)))
                } else if question != nil {
                    questionView
                        .id(questionID)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            )
                        )
                } else {
                    loadingView
                        .onAppear(perform: loadEntries)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .animation(.spring(response: 0.5, dampingFraction: 0.88), value: questionID)
            .animation(.easeInOut(duration: 0.4), value: quizFinished)

            // Confetti sits above everything on the results screen
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
        }
        .sheet(isPresented: $showReview) {
            QuizReviewView(reviewItems: reviewItems)
        }
    }

    // ── Top bar ──────────────────────────────────────────────

    var topBar: some View {
        VStack(spacing: 14) {
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.vertical, 9)
                    .padding(.horizontal, 16)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 0.8)
                            )
                    )
                }

                Spacer()

                if !quizFinished && question != nil {
                    Text("\(min(questionCount + 1, totalQuestions)) of \(totalQuestions)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Text(selectedCategory)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.white)

            // Hairline progress bar
            if !quizFinished && question != nil {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.12))

                        Capsule()
                            .fill(Color.white.opacity(0.85))
                            .frame(
                                width: geo.size.width * CGFloat(questionCount) / CGFloat(totalQuestions)
                            )
                            .animation(.easeInOut(duration: 0.5), value: questionCount)
                    }
                }
                .frame(height: 3)
                .padding(.horizontal, 8)
            }
        }
    }

    // ── Loading ──────────────────────────────────────────────

    var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.3)

            Text("Preparing your quiz")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 80)
    }

    // ── Question ─────────────────────────────────────────────

    var questionView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                Text("WHAT IS THE KISTANIGNA TRANSLATION OF")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .kerning(2.5)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)

                Text(promptText)
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.8)
                            )
                    )

                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        answerButton(for: option)
                    }
                }
                .padding(.top, 4)

                if let selected = answerSelected {
                    feedbackPanel(selected: selected)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.black.opacity(0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.8)
                    )
            )
            .padding(.bottom, 40)
        }
    }

    func answerButton(for option: String) -> some View {
        Button {
            guard answerSelected == nil else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                answerSelected = option
            }
            if option == correctAnswer {
                score += 1
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        } label: {
            HStack {
                Text(option)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Spacer()

                if let selected = answerSelected {
                    if option == correctAnswer {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.95))
                            .transition(.scale.combined(with: .opacity))
                    } else if option == selected {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.95))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(buttonColor(for: option))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.8)
                    )
            )
            .opacity(dimmedOpacity(for: option))
            .scaleEffect(answerSelected == option ? 1.02 : 1.0)
        }
        .disabled(answerSelected != nil)
    }

    func feedbackPanel(selected: String) -> some View {
        VStack(spacing: 14) {
            Text(selected == correctAnswer ? "Correct" : "Incorrect")
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(selected == correctAnswer ? .green : .red)

            if selected != correctAnswer {
                Text("Correct answer: \(correctAnswer)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }

            Button {
                nextQuestion()
            } label: {
                Text(questionCount + 1 >= totalQuestions ? "See Results" : "Next Question")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(themeGreen)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 36)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.92))
                            .shadow(color: Color.white.opacity(0.15), radius: 12)
                    )
            }
        }
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
    }

    // ── Results ──────────────────────────────────────────────

    var resultsView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 26) {
                Text("QUIZ COMPLETE")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .kerning(3.5)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 10)

                ZStack {
                    // Soft halo behind the ring
                    Circle()
                        .fill(Color.green.opacity(0.12))
                        .frame(width: 230, height: 230)
                        .blur(radius: 30)
                        .opacity(animateRing ? 1 : 0)

                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 10)
                        .frame(width: 190, height: 190)

                    Circle()
                        .trim(from: 0, to: animateRing ? CGFloat(score) / CGFloat(totalQuestions) : 0)
                        .stroke(
                            Color.green,
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 190, height: 190)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: Color.green.opacity(0.4), radius: 12)

                    VStack(spacing: 4) {
                        Text("\(displayedScore)")
                            .font(.system(size: 58, weight: .bold, design: .serif))
                            .foregroundColor(.white)

                        Text("of \(totalQuestions)")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.55))
                    }
                }
                .onAppear(perform: runResultsAnimation)

                Text(performanceText)
                    .font(.system(size: 17, weight: .medium, design: .serif))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                HStack(spacing: 14) {
                    Button {
                        showReview = true
                    } label: {
                        Text("Review Answers")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.8)
                                    )
                            )
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            resetQuiz()
                        }
                    } label: {
                        Text("Play Again")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(themeGreen)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.92))
                            )
                    }
                }
                .padding(.top, 6)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(Color.black.opacity(0.18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.8)
                    )
            )
            .padding(.bottom, 40)
        }
    }

    func runResultsAnimation() {
        animateRing = false
        displayedScore = 0
        showConfetti = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 1.4)) {
                animateRing = true
            }

            // Count-up score
            guard score > 0 else { return }
            let stepTime = 1.2 / Double(score)
            for i in 1...score {
                DispatchQueue.main.asyncAfter(deadline: .now() + stepTime * Double(i)) {
                    displayedScore = i
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
            }

            // Confetti for a good score
            if Double(score) / Double(totalQuestions) >= 0.7 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    showConfetti = true
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    // Let it fall, then clean up
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                        withAnimation(.easeOut(duration: 0.6)) {
                            showConfetti = false
                        }
                    }
                }
            }
        }
    }

    // ── Helpers (your original logic — untouched) ───────────

    var performanceText: String {
        let percentage = (Double(score) / Double(totalQuestions)) * 100

        if percentage >= 90 {
            return "Excellent! You're a Kistanigna master!"
        } else if percentage >= 70 {
            return "Great job! You're getting really good at Kistanigna!"
        } else if percentage >= 50 {
            return "Good effort! Keep practicing to improve your Kistanigna skills."
        } else {
            return "Keep practicing! You'll get better with time."
        }
    }

    func buttonColor(for option: String) -> Color {
        guard let selected = answerSelected else {
            return Color.white.opacity(0.1)
        }

        if option == correctAnswer {
            return Color.green.opacity(0.75)
        } else if option == selected {
            return Color.red.opacity(0.7)
        } else {
            return Color.white.opacity(0.05)
        }
    }

    func dimmedOpacity(for option: String) -> Double {
        guard let selected = answerSelected else { return 1.0 }
        if option == correctAnswer || option == selected { return 1.0 }
        return 0.45
    }

    func loadEntries() {
        let blockedTerms = ["hell", "sex", "sexual", "damn", "naked", "curse", "violence", "kill"]

        let allEntries = DictionaryLoader.loadFull().filter { entry in
            let combined = "\(entry.word.lowercased()) \(entry.english.lowercased()) \(entry.amharic.lowercased())"
            return !blockedTerms.contains { combined.contains($0) } &&
                !entry.word.isEmpty &&
                !entry.english.isEmpty &&
                !entry.amharic.isEmpty
        }

        entries = filterEntriesByCategory(from: allEntries)
        resetQuiz()
    }

    func filterEntriesByCategory(from entries: [DictionaryEntry]) -> [DictionaryEntry] {
        switch selectedCategory.lowercased() {
        case "greetings":
            return entries.filter { $0.english.contains("hello") || $0.amharic.contains("ሰላም") }
        case "animals":
            return entries.filter { $0.english.contains("dog") || $0.english.contains("cat") || $0.english.contains("goat") }
        case "food & drink":
            return entries.filter { $0.english.contains("bread") || $0.english.contains("coffee") || $0.english.contains("milk") }
        case "common phrases":
            return entries.filter { $0.english.contains("thank") || $0.english.contains("sorry") || $0.english.contains("please") }
        case "travel":
            return entries.filter { $0.english.contains("bus") || $0.english.contains("car") || $0.english.contains("road") }
        case "everyday words":
            return entries.filter { $0.english.count < 7 }
        default:
            return entries
        }
    }

    func nextQuestion() {
        if question != nil {
            let review = QuizReviewItem(prompt: promptText, correct: correctAnswer, selected: answerSelected)
            reviewItems.append(review)
        }

        answerSelected = nil
        questionCount += 1

        if questionCount >= totalQuestions {
            quizFinished = true
            return
        }

        generateNewQuestion()
        questionID += 1   // triggers slide transition to the new question
    }

    func generateNewQuestion() {
        guard entries.count >= 4 else { return }

        guard let newQuestion = entries.randomElement() else { return }

        let useEnglish = Bool.random()
        promptText = useEnglish ? newQuestion.english : newQuestion.amharic
        correctAnswer = newQuestion.word

        let wrongAnswers = Set(entries.lazy
            .map(\.word)
            .filter { $0 != newQuestion.word && !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .shuffled()
            .prefix(3))

        guard wrongAnswers.count == 3 else { return }

        question = newQuestion
        options = (Array(wrongAnswers) + [correctAnswer]).shuffled()
    }

    func resetQuiz() {
        score = 0
        questionCount = 0
        quizFinished = false
        answerSelected = nil
        reviewItems = []
        animateRing = false
        displayedScore = 0
        showConfetti = false
        generateNewQuestion()
        questionID += 1
    }
}

// ─────────────────────────────────────────────────────────────
//  Confetti — lightweight Canvas particle burst (iOS 15+)
// ─────────────────────────────────────────────────────────────

struct ConfettiView: View {
    private struct Particle {
        let x: CGFloat          // 0...1 horizontal start
        let delay: Double
        let speed: Double       // fall speed multiplier
        let sway: CGFloat       // horizontal sway amplitude
        let swayFreq: Double
        let size: CGFloat
        let color: Color
        let spin: Double
    }

    private let particles: [Particle] = {
        let palette: [Color] = [
            .green, .white,
            Color(red: 0.7, green: 0.9, blue: 0.6),
            Color(red: 0.95, green: 0.85, blue: 0.5),
            Color(red: 0.6, green: 0.8, blue: 1.0)
        ]
        return (0..<70).map { _ in
            Particle(
                x: CGFloat.random(in: 0...1),
                delay: Double.random(in: 0...0.8),
                speed: Double.random(in: 0.7...1.4),
                sway: CGFloat.random(in: 12...45),
                swayFreq: Double.random(in: 1.5...3.5),
                size: CGFloat.random(in: 5...10),
                color: palette.randomElement() ?? .white,
                spin: Double.random(in: -4...4)
            )
        }
    }()

    @State private var startDate = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSince(startDate)

                for p in particles {
                    let localT = t - p.delay
                    guard localT > 0 else { continue }

                    let progress = localT * p.speed / 3.0
                    guard progress < 1.2 else { continue }

                    let y = -30 + (size.height + 60) * CGFloat(progress)
                    let x = p.x * size.width
                        + p.sway * CGFloat(sin(localT * p.swayFreq * .pi))
                    let fade = progress > 0.85
                        ? max(0, 1 - (progress - 0.85) / 0.35)
                        : 1

                    var ctx = context
                    ctx.opacity = fade
                    ctx.translateBy(x: x, y: y)
                    ctx.rotate(by: .radians(localT * p.spin))

                    let rect = CGRect(
                        x: -p.size / 2,
                        y: -p.size / 2,
                        width: p.size,
                        height: p.size * 0.6
                    )
                    ctx.fill(
                        Path(roundedRect: rect, cornerRadius: 1.5),
                        with: .color(p.color)
                    )
                }
            }
        }
        .onAppear {
            startDate = Date()
        }
    }
}
