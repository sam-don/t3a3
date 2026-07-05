import SwiftUI

struct ProgressBarView: View {
    let fraction: Double
    let tint: Color
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.primary.opacity(0.12))
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(tint)
                    .frame(width: max(0, min(1, fraction)) * geo.size.width)
            }
        }
        .frame(height: height)
    }
}
