import SwiftUI

struct CurrencyBadge: View {
    let systemImage: String
    let value: Double
    let tint: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
                .font(.footnote.weight(.semibold))
            Text(value.abbreviated())
                .font(.footnote.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(Color.white.opacity(0.08))
        )
        .overlay(
            Capsule().strokeBorder(tint.opacity(0.35), lineWidth: 1)
        )
    }
}
