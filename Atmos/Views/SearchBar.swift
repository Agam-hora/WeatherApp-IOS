import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var isSearching: Bool
    var onSubmit: () -> Void
    var onClear: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.callout)
                    .foregroundStyle(.white.opacity(0.6))

                TextField("Search city...", text: $text)
                    .font(.callout)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .onSubmit(onSubmit)
                    .autocorrectionDisabled()

                if isSearching {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.7)
                } else if !text.isEmpty {
                    Button {
                        text = ""
                        onClear()
                        isFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.callout)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .glassCard(cornerRadius: 14)

            if isFocused {
                Button("Cancel") {
                    text = ""
                    onClear()
                    isFocused = false
                }
                .font(.callout)
                .foregroundStyle(.white)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: isFocused)
    }
}
