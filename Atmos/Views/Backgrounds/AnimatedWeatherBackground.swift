import SwiftUI

struct AnimatedWeatherBackground: View {
    let condition: WeatherCondition
    let isNight: Bool

    @State private var animateGradient = false
    @State private var starOpacity: [Double] = (0..<30).map { _ in Double.random(in: 0.2...1.0) }
    @State private var starPositions: [(x: CGFloat, y: CGFloat, size: CGFloat)] = (0..<30).map { _ in
        (x: CGFloat.random(in: 0...1), y: CGFloat.random(in: 0...0.6), size: CGFloat.random(in: 1...3))
    }

    var body: some View {
        ZStack {
            // Base animated gradient
            LinearGradient(
                colors: condition.gradientColors(isNight: isNight),
                startPoint: animateGradient ? .topLeading : .topTrailing,
                endPoint: animateGradient ? .bottomTrailing : .bottomLeading
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateGradient)

            // Weather-specific overlays
            if isNight && (condition == .clear || condition == .fewClouds) {
                starsOverlay
            }

            if condition == .rain || condition == .drizzle {
                RainView()
            }

            if condition == .snow {
                SnowView()
            }

            if condition == .clouds || condition == .fewClouds {
                cloudsOverlay
            }

            if condition == .thunderstorm {
                ThunderstormView()
            }
        }
        .onAppear {
            animateGradient = true
        }
    }

    // MARK: - Stars
    private var starsOverlay: some View {
        Canvas { context, size in
            for i in 0..<30 {
                let pos = starPositions[i]
                let x = pos.x * size.width
                let y = pos.y * size.height
                let rect = CGRect(x: x, y: y, width: pos.size, height: pos.size)
                context.opacity = starOpacity[i]
                context.fill(Circle().path(in: rect), with: .color(.white))
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                starOpacity = starOpacity.map { _ in Double.random(in: 0.2...1.0) }
            }
        }
    }

    // MARK: - Clouds
    private var cloudsOverlay: some View {
        GeometryReader { geo in
            ZStack {
                CloudShape()
                    .fill(.white.opacity(0.08))
                    .frame(width: 300, height: 120)
                    .offset(x: animateGradient ? geo.size.width * 0.3 : -geo.size.width * 0.1, y: geo.size.height * 0.15)

                CloudShape()
                    .fill(.white.opacity(0.06))
                    .frame(width: 250, height: 100)
                    .offset(x: animateGradient ? -geo.size.width * 0.1 : geo.size.width * 0.4, y: geo.size.height * 0.25)

                CloudShape()
                    .fill(.white.opacity(0.05))
                    .frame(width: 200, height: 80)
                    .offset(x: animateGradient ? geo.size.width * 0.5 : geo.size.width * 0.1, y: geo.size.height * 0.1)
            }
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateGradient)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Cloud Shape
struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.25, y: h * 0.8))
        path.addQuadCurve(to: CGPoint(x: w * 0.1, y: h * 0.5),
                          control: CGPoint(x: w * 0.05, y: h * 0.75))
        path.addQuadCurve(to: CGPoint(x: w * 0.3, y: h * 0.2),
                          control: CGPoint(x: w * 0.1, y: h * 0.2))
        path.addQuadCurve(to: CGPoint(x: w * 0.55, y: h * 0.15),
                          control: CGPoint(x: w * 0.4, y: h * 0.05))
        path.addQuadCurve(to: CGPoint(x: w * 0.8, y: h * 0.3),
                          control: CGPoint(x: w * 0.7, y: h * 0.1))
        path.addQuadCurve(to: CGPoint(x: w * 0.9, y: h * 0.6),
                          control: CGPoint(x: w * 0.95, y: h * 0.4))
        path.addQuadCurve(to: CGPoint(x: w * 0.75, y: h * 0.8),
                          control: CGPoint(x: w * 0.95, y: h * 0.85))
        path.closeSubpath()
        return path
    }
}

// MARK: - Rain Particles
struct RainView: View {
    @State private var drops: [RainDrop] = (0..<30).map { _ in RainDrop.random() }
    @State private var animate = false

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { timeline in
            Canvas { context, size in
                for drop in drops {
                    let y = animate
                        ? (drop.startY + CGFloat(timeline.date.timeIntervalSinceReferenceDate * drop.speed * 100).truncatingRemainder(dividingBy: size.height + 50))
                        : drop.startY
                    let adjustedY = y.truncatingRemainder(dividingBy: size.height + 50) - 25

                    var path = Path()
                    path.move(to: CGPoint(x: drop.x * size.width, y: adjustedY))
                    path.addLine(to: CGPoint(x: drop.x * size.width + drop.windOffset, y: adjustedY + drop.length))

                    context.opacity = drop.opacity
                    context.stroke(path, with: .color(.white.opacity(0.4)), lineWidth: drop.width)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear { animate = true }
    }
}

struct RainDrop {
    let x: CGFloat
    let startY: CGFloat
    let length: CGFloat
    let width: CGFloat
    let speed: Double
    let opacity: Double
    let windOffset: CGFloat

    static func random() -> RainDrop {
        RainDrop(
            x: CGFloat.random(in: 0...1),
            startY: CGFloat.random(in: -100...0),
            length: CGFloat.random(in: 15...30),
            width: CGFloat.random(in: 0.5...1.5),
            speed: Double.random(in: 3...7),
            opacity: Double.random(in: 0.2...0.6),
            windOffset: CGFloat.random(in: -3...3)
        )
    }
}

// MARK: - Snow Particles
struct SnowView: View {
    @State private var flakes: [SnowFlake] = (0..<20).map { _ in SnowFlake.random() }

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                for flake in flakes {
                    let progress = (CGFloat(time * flake.speed * 30) + flake.startY)
                        .truncatingRemainder(dividingBy: size.height + 20) - 10
                    let wobble = sin(time * flake.wobbleSpeed + flake.wobblePhase) * flake.wobbleAmount
                    let x = flake.x * size.width + wobble

                    let rect = CGRect(x: x, y: progress, width: flake.size, height: flake.size)
                    context.opacity = flake.opacity
                    context.fill(Circle().path(in: rect), with: .color(.white))
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct SnowFlake {
    let x: CGFloat
    let startY: CGFloat
    let size: CGFloat
    let speed: Double
    let opacity: Double
    let wobbleSpeed: Double
    let wobbleAmount: CGFloat
    let wobblePhase: Double

    static func random() -> SnowFlake {
        SnowFlake(
            x: CGFloat.random(in: 0...1),
            startY: CGFloat.random(in: 0...800),
            size: CGFloat.random(in: 2...6),
            speed: Double.random(in: 0.5...2),
            opacity: Double.random(in: 0.4...0.9),
            wobbleSpeed: Double.random(in: 1...3),
            wobbleAmount: CGFloat.random(in: 10...30),
            wobblePhase: Double.random(in: 0...Double.pi * 2)
        )
    }
}

// MARK: - Thunderstorm
struct ThunderstormView: View {
    @State private var flashOpacity: Double = 0

    var body: some View {
        ZStack {
            RainView()

            Color.white.opacity(flashOpacity)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
        .onAppear {
            triggerFlash()
        }
    }

    private func triggerFlash() {
        let delay = Double.random(in: 2...6)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeIn(duration: 0.05)) {
                flashOpacity = 0.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.15)) {
                    flashOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeIn(duration: 0.03)) {
                        flashOpacity = 0.15
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            flashOpacity = 0
                        }
                        triggerFlash()
                    }
                }
            }
        }
    }
}
