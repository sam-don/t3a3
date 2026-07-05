import SwiftUI

struct CurrencyBadge: View {
    let systemImage: String
    let value: Double
    let tint: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
            Text(value.abbreviated())
                .fontWeight(.semibold)
                .monospacedDigit()
        }
        .font(.subheadline)
    }
}
