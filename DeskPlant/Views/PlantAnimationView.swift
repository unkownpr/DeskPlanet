import SwiftUI

struct PlantAnimationView: View {
    @ObservedObject var plantState: PlantState
    @State private var isAnimating = false
    @State private var leaves: [LeafData] = []

    var body: some View {
        ZStack {
            // Background gradient based on time of day
            LinearGradient(
                gradient: backgroundGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .opacity(0.3)

            VStack(spacing: 0) {
                // Leaves/Crown
                ZStack {
                    ForEach(leaves) { leaf in
                        LeafView(data: leaf, isAnimating: isAnimating)
                    }
                }
                .frame(height: 80 * plantState.size)

                // Plant emoji (main body) - Changes based on health
                Text(currentPlantEmoji)
                    .font(.system(size: 60 * plantState.size))
                    .scaleEffect(healthScaleEffect)
                    .opacity(healthOpacity)
                    .rotationEffect(wiltingRotation)
                    .offset(y: wiltingOffset)
                    .onAppear {
                        // Simplified breathing animation
                        withAnimation(
                            .easeInOut(duration: breathingDuration)
                            .repeatForever(autoreverses: true)
                        ) {
                            isAnimating = true
                        }
                    }

                // Pot
                PotView(plantType: plantState.type)
                    .frame(width: 80 * plantState.size, height: 40 * plantState.size)
            }

            // Particle effects - Disabled for performance
            // Water particles can cause lag on slower machines
        }
        .frame(width: 200, height: 250)
        .onAppear {
            generateLeaves()
        }
        .onChange(of: plantState.level) { _ in
            generateLeaves()
        }
        .onChange(of: plantState.health) { _ in
            // Regenerate leaves when health changes significantly
            generateLeaves()
        }
        .drawingGroup() // Performance optimization - renders as single layer
    }

    private var backgroundGradient: Gradient {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 6..<12: // Morning
            return Gradient(colors: [Color.orange.opacity(0.3), Color.yellow.opacity(0.2)])
        case 12..<18: // Afternoon
            return Gradient(colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.2)])
        case 18..<21: // Evening
            return Gradient(colors: [Color.purple.opacity(0.3), Color.orange.opacity(0.2)])
        default: // Night
            return Gradient(colors: [Color.indigo.opacity(0.4), Color.black.opacity(0.3)])
        }
    }

    private var healthOpacity: Double {
        return 0.3 + (plantState.health / 100.0 * 0.7)
    }
    
    /// Current emoji based on health status
    private var currentPlantEmoji: String {
        switch plantState.health {
        case 0..<20:
            return plantState.type.criticalEmoji
        case 20..<40:
            return plantState.type.wiltingEmoji
        default:
            return plantState.type.emoji
        }
    }
    
    /// Breathing animation duration - slower when unhealthy
    private var breathingDuration: Double {
        switch plantState.health {
        case 0..<20:
            return 4.0  // Very slow, struggling
        case 20..<40:
            return 3.0  // Slow
        case 40..<60:
            return 2.5  // Slightly slow
        default:
            return 2.0  // Normal
        }
    }
    
    /// Scale effect based on health
    private var healthScaleEffect: CGFloat {
        let baseScale: CGFloat = isAnimating ? 1.05 : 1.0
        
        switch plantState.health {
        case 0..<20:
            return baseScale * 0.8  // Shrunk
        case 20..<40:
            return baseScale * 0.9  // Slightly shrunk
        default:
            return baseScale
        }
    }
    
    /// Rotation effect when wilting
    private var wiltingRotation: Angle {
        switch plantState.health {
        case 0..<20:
            return .degrees(15)  // Heavily tilted
        case 20..<40:
            return .degrees(8)   // Slightly tilted
        default:
            return .degrees(0)
        }
    }
    
    /// Vertical offset when wilting (drooping)
    private var wiltingOffset: CGFloat {
        switch plantState.health {
        case 0..<20:
            return 10  // Drooping down
        case 20..<40:
            return 5   // Slightly drooping
        default:
            return 0
        }
    }

    private func generateLeaves() {
        // Leaf count affected by health and level
        let healthFactor = plantState.health / 100.0
        let baseLeafCount = 3 + plantState.level / 2
        let healthAdjustedCount = Int(Double(baseLeafCount) * healthFactor)
        let leafCount = min(max(healthAdjustedCount, 1), 8)
        
        leaves = (0..<leafCount).map { i in
            let baseSize = 10 + Double(i % 3) * 4
            // Leaves shrink when unhealthy
            let healthAdjustedSize = baseSize * healthFactor
            
            return LeafData(
                id: i,
                angle: Double(i) * (360.0 / Double(leafCount)),
                distance: 20 + Double(i % 3) * 10,
                size: max(healthAdjustedSize, 5) // Minimum size
            )
        }
    }
}

// MARK: - Leaf Data
struct LeafData: Identifiable {
    let id: Int
    let angle: Double
    let distance: Double
    let size: Double
}

// MARK: - Leaf View
struct LeafView: View {
    let data: LeafData
    let isAnimating: Bool
    @State private var rotation: Double = 0
    @State private var isFalling: Bool = false

    var body: some View {
        Circle()
            .fill(leafColor)
            .frame(width: data.size, height: data.size)
            .offset(
                x: cos(data.angle * .pi / 180) * data.distance,
                y: sin(data.angle * .pi / 180) * data.distance
            )
            .rotationEffect(.degrees(rotation))
            .opacity(leafOpacity)
            .onAppear {
                // Simplified animation - only trigger once
                withAnimation(
                    .easeInOut(duration: 3.0 + Double(data.id % 3))
                    .repeatForever(autoreverses: true)
                ) {
                rotation = Double.random(in: -15...15)
            }
            }
    }
    
    private var leafColor: Color {
        // Leaves turn brown when unhealthy
        if data.size < 8 { // Unhealthy indicator
            return Color.brown.opacity(0.5)
        }
        return Color.green.opacity(0.6)
    }
    
    private var leafOpacity: Double {
        // Leaves fade when unhealthy
        if data.size < 8 {
            return 0.3
        }
        return 0.8
    }
}

// MARK: - Pot View
struct PotView: View {
    let plantType: PlantType

    var body: some View {
        ZStack {
            // Pot shape
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.brown.opacity(0.8),
                            Color.brown.opacity(0.6)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Pot rim
            Rectangle()
                .fill(Color.brown.opacity(0.9))
                .frame(height: 5)
                .offset(y: -17.5)

            // Soil
            Ellipse()
                .fill(Color.brown.opacity(0.9))
                .frame(height: 15)
                .offset(y: -12)
        }
    }
}

// MARK: - Water Particles
struct WaterParticles: View {
    @State private var particles: [ParticleData] = []
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.blue.opacity(0.6))
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            startParticleAnimation()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startParticleAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Add new particle
            if particles.count < 10 {
                particles.append(ParticleData(
                    position: CGPoint(x: 100, y: 180),
                    velocity: CGPoint(
                        x: Double.random(in: -2...2),
                        y: Double.random(in: -5...(-2))
                    ),
                    size: Double.random(in: 3...6),
                    opacity: 1.0
                ))
            }

            // Update existing particles
            particles = particles.compactMap { particle in
                var updated = particle
                updated.position.x += particle.velocity.x
                updated.position.y += particle.velocity.y
                updated.velocity.y += 0.2 // Gravity
                updated.opacity -= 0.02

                return updated.opacity > 0 ? updated : nil
            }
        }
    }
}

struct ParticleData: Identifiable {
    let id = UUID()
    var position: CGPoint
    var velocity: CGPoint
    var size: Double
    var opacity: Double
}

// MARK: - Preview
struct PlantAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        PlantAnimationView(plantState: PlantState(type: .bonsai))
    }
}
