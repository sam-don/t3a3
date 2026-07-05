import SwiftUI

struct ProgressBarView: View {
    let fraction: Double
    let tint: Color
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            let clamped = max(0, min(1, fraction))
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.black.opacity(0.35))
                    .overlay(
                        RoundedRectangle(cornerRadius: height / 2)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [tint.opacity(0.75), tint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: clamped <= 0 ? 0 : max(height, clamped * geo.size.width))
                    .shadow(color: tint.opacity(0.6), radius: clamped > 0 ? 4 : 0)
            }
        }
        .frame(height: height)
    }
}
