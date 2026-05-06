import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)

                Image(systemName: errorIcon)
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.6))
                    .symbolEffect(.pulse, options: .repeating)
            }

            VStack(spacing: 10) {
                Text(errorTitle)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Button(action: retryAction) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
                .background(.white.opacity(0.15), in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 0.5))
            }
            .padding(.top, 8)

            Spacer()
        }
        .onAppear { isAnimating = true }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }

    private var errorIcon: String {
        if message.contains("denied") || message.contains("Location") {
            return "location.slash.fill"
        } else if message.contains("internet") || message.contains("Network") || message.contains("network") {
            return "wifi.slash"
        } else {
            return "exclamationmark.icloud.fill"
        }
    }

    private var errorTitle: String {
        if message.contains("denied") || message.contains("Location") {
            return "Location Unavailable"
        } else if message.contains("internet") || message.contains("Network") || message.contains("network") {
            return "No Connection"
        } else {
            return "Something Went Wrong"
        }
    }
}
