import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Placeholder header
            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.15))
                    .frame(width: 120, height: 18)
                    .shimmer()

                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.15))
                    .frame(width: 160, height: 14)
                    .shimmer()

                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .shimmer()

                RoundedRectangle(cornerRadius: 10)
                    .fill(.white.opacity(0.15))
                    .frame(width: 100, height: 50)
                    .shimmer()

                RoundedRectangle(cornerRadius: 8)
                    .fill(.white.opacity(0.15))
                    .frame(width: 140, height: 16)
                    .shimmer()
            }

            // Placeholder hourly
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.08))
                .frame(height: 140)
                .padding(.horizontal, 20)
                .shimmer()

            // Placeholder weekly
            RoundedRectangle(cornerRadius: 20)
                .fill(.white.opacity(0.08))
                .frame(height: 280)
                .padding(.horizontal, 20)
                .shimmer()

            // Placeholder grid
            HStack(spacing: 12) {
                ForEach(0..<2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.08))
                        .frame(height: 80)
                        .shimmer()
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .transition(.opacity)
    }
}
