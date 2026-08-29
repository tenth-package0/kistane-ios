import SwiftUI

struct Tradition: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let images: [String]
    let tags: [String]
    
    static func == (lhs: Tradition, rhs: Tradition) -> Bool {
        lhs.id == rhs.id
    }
}

struct TraditionsTab: View {
    let traditions: [Tradition] = [
        Tradition(
            title: "ጥንስስ",
            description: "ጠላ መጫጫቅ የሚጀመርበት የመጀመሪያ ቀን ኝንሰስ ይባላል፤፤ ጠላው የዛኔ ተጠንስሶ ይባላል፤፤ ጠላ ለመጠንስስ የሚያስፈልገው ጌሾ ፣ ብቅል እና ውሃ ነው፤፤ (የተፈጨ እና የተወቀጠ)፤፤ አንድላይ ተሰባጥሮ ይቀመጣል:: ለሰርግ ጊዜ እናትየው ቅቤ ምትቀባው የኝንሰስ ቀን ነው፤፤ የዛን ቀን ቆንጮ ተቆንጥሎ ይበላል ::",
            images: ["tradition1", "tradition1_detail1", "tradition1_detail2"],
            tags: ["Ceremony", "Cultural"]
        ),
        Tradition(
            title: "ብስቆት",
            description: "የሙሽራ እናት ጓደኞች ከሰርግ በቀን/በፊት አንድላይ ተሰባስበው ለሙሽራ/ለሙሽሪት እናት ስጦታ የሚሰጡበት ቀን ነው:: ሴቶች እና እናቶች እዛ የሚገኙትን ቀን ነው:: ይበላል ፣ ይጠጣል ፣ ይጨፈራል::",
            images: ["tradition2", "tradition2_detail1", "tradition2_detail2"],
            tags: ["Ritual", "Family"]
        ),
        Tradition(
            title: "እንሾሽላ",
            description: "እንጆሽላ ማለት ሁለት ከሰርግ ዋዜማ 1 ቀን በፊት ዘመዶች ፣ ጓደኛ ፣ ጎረቤት ሁሉ ተሰባስቦ የሚጨፍርበት ቀን ነው:: የዛን ቀን ዳቦ እና ጠላ ይዘጋጃል:: ሙሽራው እና ሙሽሪት ለየብቻቸው ነው የሚያዘጋጁት፤ የዛጠመቀው ጠላ ለመጀመሪያ ጊዜ የሚጠጣው ይሄ ቀን ነው:: የዘር ቁጠራ ይደረጋል፤ የዘር ሀረግ በዘር 3 [በሁለቱ] መካከል የሚነገርበት ቀን ነው::",
            images: ["tradition3", "tradition3_detail1", "tradition3_detail2"],
            tags: ["Festival", "Art"]
        ),
        Tradition(
            title: "ምርቃት",
            description: "ክስታኔዎች በምርቃት ላይ ያላቸው እምነት ከፍተኛ ነው። በማንኛውም ማህበራዊ ግንኙነት ላይ የክስታኔ ሽማግሌዎች ምርቃት መርቀው የዝጌር ኬር ዬሁን ማለት የተለመደ ነው። በማንኛውም ማህበራዊ ግንኙነት ላይ የክስታኔ ሽማግሌዎች ምርቃት መርቀው የዝጌር ኬር ዬሁን ማለት የተለመደ ነው። በሀገር ልማት፣ የአስተዳደር፣ በእርቅ ጉዳይ፣ በቤተሰብ ጉዳይ፣ በሰርግና በማንኛውም የግብዣ ሥነሥርዓት ላይ ማህበረሰቡ ሲገናኝ ሽማግሌዎች ሀገር ሰላም እንዲሆን፣ የሀገር መሪዎች ከክፉ እንዲጠበቁ፣ ለመንደሩ፣ ለምድሪቱም የወቅቱ ዝናብ በአግባቡ እንዲዘንብ እና ሰብሎች እንዲበቅሉ፣ ወጣቱም በተሰማራበት የሥራ መስክ ስኬታማ እንዲሆን፣...ከልባቸው ይመርቃሉ።ክስታኔዎች በመመረቅ ወደር የላቸውም ቢባል ማጋነን አይሆንም ለዚህም ዋናው ማሳያ በየትኛውም ስፍራ የክስታኔ ተወላጆች ሀርግም ሆነ ማንኛውም ድግስ ደግሰው ከተበላና ከተጠጣ በኃላ ሶስት(3) ወይም አምስት (5) ሽማግሌዎች አንዳንዴም ሰባት ሽማግሌዎች በየተራ ሲመርቁ ሌላው ህዝብ #አሚን በማለት ምርቃቱን ያፀድቃል። ሽማግሌዎች ወይም እናቶች መርቀው ሲጨርሱ ኬር ይሁን በማለት ህዝቡ ሁሉ ህብር ባለው ዜማዊ ድምፅ ያስተጋባል። መመረቅ ለክስታኔ ጉራጌ ተወላጅ የህይወት ዘይቤ ነው ማለት ይቻላል።",
            images: ["tradition4", "tradition4_detail1", "tradition4_detail2", "tradition4_detail3"],
            tags: ["Blessing", "Elders", "Community"]
        ),
        Tradition(
            title: "ቸግ",
            description: "ማለት አንድ ወንድ ሚስት ማግባት ሲፈልግ ለቤተሰቦቿ ሽማግሌ ይልክና ሲቀበሉት የሚደረግ ግብዣ ነው፤፤ መጀመሪያ 2 ወይም 3 ሰው ይልካል፤፤ የሁለተኛ ቀን የተፈቀደለት ነው ቸግ የሚባለው::",
            images: ["tradition5", "tradition5_detail1"],
            tags: ["Harvest", "Food"]
        ),
        Tradition(
            title: "ደንጌሳ",
            description: "ከመስከረም ፲፮ [16] ሴቷ የምታዘጋጀው ኣይቤ እና ጎመን ብቻ የሚበላበት ቀን፤፤ ሴቷ ናት ራሷ የምታዘጋጀው፤፤ በማግስቱ ይታረድ እና ክትፎ ይበላል ::",
            images: ["tradition6", "tradition6_detail1", "tradition6_detail2"],
            tags: ["Seasonal", "Prosperity"]
        )
    ]

    @State private var selectedTradition: Tradition? = nil
    @State private var animateTraditions = false
    
    var body: some View {
        ZStack {
            // Elegant background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.1),
                    Color(red: 0.2, green: 0.3, blue: 0.2)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Modern, clean header
                Text("Traditions")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                
                // Elegant scrolling grid - no filter bubbles
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(Array(traditions.enumerated()), id: \.element.id) { index, tradition in
                            TraditionCard(
                                tradition: tradition,
                                index: index,
                                onTap: {
                                    selectedTradition = tradition
                                }
                            )
                            .opacity(animateTraditions ? 1.0 : 0.0)
                            .offset(y: animateTraditions ? 0 : 50)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(Double(index) * 0.1),
                                value: animateTraditions
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            
            // Elegant detail overlay
            if let tradition = selectedTradition {
                TraditionDetailOverlay(
                    tradition: tradition,
                    onClose: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedTradition = nil
                        }
                    }
                )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateTraditions = true
            }
        }
        .onDisappear {
            animateTraditions = false
        }
    }
}

struct TraditionCard: View {
    let tradition: Tradition
    let index: Int
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Main image
                Image(tradition.images[0])
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(16)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.black.opacity(0.3)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .cornerRadius(16)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: 12) {
                    Text(tradition.title)
                        .font(.system(size: 22, weight: .bold, design: .default))
                        .foregroundColor(.white)
                    
                    Text(tradition.description)
                        .font(.system(size: 14, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Subtle tag indicators
                    HStack(spacing: 8) {
                        ForEach(tradition.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct TraditionDetailOverlay: View {
    let tradition: Tradition
    let onClose: () -> Void
    
    @State private var selectedImageIndex = 0
    @State private var animateContent = false
    @State private var showFullDescription = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background - tap anywhere to close
                Rectangle()
                    .fill(Color.black.opacity(0.9))
                    .ignoresSafeArea()
                    .onTapGesture {
                        onClose()
                    }
                
                // Content container
                VStack(spacing: 0) {
                    // Close button
                    HStack {
                        Spacer()
                        
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.5))
                                )
                        }
                        .padding(20)
                    }
                    
                    // Image gallery - prevent tap through
                    TabView(selection: $selectedImageIndex) {
                        ForEach(Array(tradition.images.enumerated()), id: \.offset) { index, imageName in
                            Image(imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .tag(index)
                                .onTapGesture {
                                    // Prevent tap from going to background
                                }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 350)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        // Prevent tap from going to background
                    }
                    
                    // Title and description - prevent tap through
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text(tradition.title)
                                .font(.system(size: 28, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            // Tags
                            HStack(spacing: 10) {
                                ForEach(tradition.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.system(size: 14, weight: .medium, design: .default))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            
                            // Description
                            Text(tradition.description)
                                .font(.system(size: 16, design: .default))
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(6)
                                .lineLimit(showFullDescription ? nil : 6)
                                .multilineTextAlignment(.leading)
                            
                            if !showFullDescription && tradition.description.count > 200 {
                                Button(action: {
                                    withAnimation {
                                        showFullDescription = true
                                    }
                                }) {
                                    Text("Read more")
                                        .font(.system(size: 14, weight: .medium, design: .default))
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.top, 8)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                    .onTapGesture {
                        // Prevent tap from going to background
                    }
                }
                .background(
                    Color(red: 0.1, green: 0.15, blue: 0.1)
                        .cornerRadius(20)
                        .edgesIgnoringSafeArea(.bottom)
                )
                .scaleEffect(animateContent ? 1.0 : 0.9)
                .opacity(animateContent ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        animateContent = true
                    }
                }
                .onTapGesture {
                    // Prevent tap from going to background
                }
            }
        }
    }
}
