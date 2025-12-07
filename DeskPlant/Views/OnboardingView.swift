import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var currentPage = 0
    
    private var pages: [OnboardingPage] {
        [
            OnboardingPage(
                icon: "🌱",
                title: "onboarding.welcome.title".localized,
                description: "onboarding.welcome.description".localized
            ),
            OnboardingPage(
                icon: "⏰",
                title: "onboarding.focus.title".localized,
                description: "onboarding.focus.description".localized
            ),
            OnboardingPage(
                icon: "☕",
                title: "onboarding.break.title".localized,
                description: "onboarding.break.description".localized
            ),
            OnboardingPage(
                icon: "💧",
                title: "onboarding.care.title".localized,
                description: "onboarding.care.description".localized
            ),
            OnboardingPage(
                icon: "🌳",
                title: "onboarding.types.title".localized,
                description: "onboarding.types.description".localized,
                isPlantTypesPage: true
            ),
            OnboardingPage(
                icon: "🎯",
                title: "onboarding.start.title".localized,
                description: "onboarding.start.description".localized
            )
        ]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
            }
            
            // Content
            OnboardingPageView(page: pages[currentPage])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Page indicators
            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 8)
            
            // Footer
            HStack(spacing: 20) {
                if currentPage > 0 {
                    Button("onboarding.button.back".localized) {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .buttonStyle(SecondaryOnboardingButtonStyle())
                }
                
                Spacer()
                
                if currentPage < pages.count - 1 {
                    Button("onboarding.button.next".localized) {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(PrimaryOnboardingButtonStyle())
                } else {
                    Button("onboarding.button.start".localized) {
                        isPresented = false
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                    }
                    .buttonStyle(PrimaryOnboardingButtonStyle())
                }
            }
            .padding()
            .id(localizationManager.currentLanguage)
        }
        .frame(width: 400, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    var isPlantTypesPage: Bool = false
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        if page.isPlantTypesPage {
            PlantTypesPageView(page: page)
        } else {
            VStack(spacing: 24) {
                Text(page.icon)
                    .font(.system(size: 80))
                    .padding(.top, 40)
                
                Text(page.title)
                    .font(.title)
                    .bold()
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Plant Types Page View
struct PlantTypesPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            Text(page.icon)
                .font(.system(size: 60))
                .padding(.top, 20)
            
            Text(page.title)
                .font(.title2)
                .bold()
            
            Text(page.description)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 30)
            
            ScrollView {
                VStack(spacing: 12) {
                    // All plant types
                    OnboardingPlantCard(
                        emoji: "🌵",
                        name: "Cactus",
                        difficulty: "⭐",
                        description: "onboarding.plant.cactus".localized
                    )
                    
                    OnboardingPlantCard(
                        emoji: "🌿",
                        name: "Monstera",
                        difficulty: "⭐⭐",
                        description: "onboarding.plant.monstera".localized
                    )
                    
                    OnboardingPlantCard(
                        emoji: "🎋",
                        name: "Bamboo",
                        difficulty: "⭐⭐",
                        description: "onboarding.plant.bamboo".localized
                    )
                    
                    OnboardingPlantCard(
                        emoji: "🌳",
                        name: "Bonsai",
                        difficulty: "⭐⭐⭐",
                        description: "onboarding.plant.bonsai".localized
                    )
                    
                    OnboardingPlantCard(
                        emoji: "🌻",
                        name: "Sunflower",
                        difficulty: "⭐⭐⭐⭐",
                        description: "onboarding.plant.sunflower".localized
                    )
                    
                    OnboardingPlantCard(
                        emoji: "🌸",
                        name: "Sakura",
                        difficulty: "⭐⭐⭐⭐⭐",
                        description: "onboarding.plant.sakura".localized
                    )
                }
                .padding(.horizontal, 20)
            }
            .frame(maxHeight: 250)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Onboarding Plant Type Card
struct OnboardingPlantCard: View {
    let emoji: String
    let name: String
    let difficulty: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 32))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(name)
                        .font(.system(size: 13, weight: .semibold))
                    
                    Spacer()
                    
                    Text(difficulty)
                        .font(.system(size: 10))
                }
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Button Styles
struct PrimaryOnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 10)
            .background(Color.accentColor)
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryOnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.primary)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

