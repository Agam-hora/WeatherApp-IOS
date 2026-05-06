import SwiftUI

// MARK: - Date Extensions
extension Date {
    func formatted(as format: String, timezone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = timezone
        return formatter.string(from: self)
    }

    var hourString: String {
        formatted(as: "ha")
    }

    var dayOfWeek: String {
        formatted(as: "EEEE")
    }

    var shortDay: String {
        formatted(as: "EEE")
    }

    var dateString: String {
        formatted(as: "EEEE, MMM d")
    }

    var timeString: String {
        formatted(as: "h:mm a")
    }
}

// MARK: - Double Extensions
extension Double {
    var temperatureString: String {
        String(format: "%.0f°", self)
    }

    var speedString: String {
        String(format: "%.1f m/s", self)
    }

    var percentString: String {
        String(format: "%.0f%%", self)
    }
}

// MARK: - Int Extensions
extension Int {
    var toDate: Date {
        Date(timeIntervalSince1970: TimeInterval(self))
    }
}

// MARK: - Glassmorphism Modifier
struct GlassmorphismModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.15

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassmorphismModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Shimmer Effect
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            .clear,
                            .white.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 2)
                    .offset(x: phase * geo.size.width * 2 - geo.size.width)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Color Extensions
extension Color {
    static let atmosBlue = Color(red: 0.2, green: 0.5, blue: 0.9)
    static let atmosOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let atmosPurple = Color(red: 0.4, green: 0.2, blue: 0.8)
    static let atmosDark = Color(red: 0.08, green: 0.08, blue: 0.15)
    static let atmosGray = Color(red: 0.5, green: 0.55, blue: 0.65)
}
