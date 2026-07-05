import SwiftUI

/// Central visual identity for Idle Delve: a dark fantasy dungeon palette.
/// The game forces dark mode (see `ContentView`), so every color here is
/// tuned to read against a near-black backdrop regardless of the device's
/// system appearance setting.
enum Theme {
    static let backgroundTop = Color(red: 0.13, green: 0.08, blue: 0.20)
    static let backgroundBottom = Color(red: 0.035, green: 0.025, blue: 0.06)

    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [backgroundTop, backgroundBottom], startPoint: .top, endPoint: .bottom)
    }

    static let cardFill = Color.white.opacity(0.055)
    static let cardStroke = Color.white.opacity(0.10)
    static let rowFill = Color.white.opacity(0.035)

    static let gold = Color(red: 0.87, green: 0.66, blue: 0.31)
    static let essence = Color(red: 0.93, green: 0.42, blue: 0.80)
    static let hp = Color(red: 0.36, green: 0.80, blue: 0.49)
    static let hpLow = Color(red: 0.86, green: 0.32, blue: 0.36)
    static let xpColor = Color(red: 0.64, green: 0.48, blue: 0.96)

    static var goldGradient: LinearGradient {
        LinearGradient(colors: [gold, Color(red: 0.62, green: 0.42, blue: 0.14)], startPoint: .top, endPoint: .bottom)
    }

    static var essenceGradient: LinearGradient {
        LinearGradient(colors: [essence, Color(red: 0.55, green: 0.20, blue: 0.55)], startPoint: .top, endPoint: .bottom)
    }
}

/// A frosted, subtly bordered card — the base surface every section of the
/// UI sits on top of the dungeon backdrop.
struct CardBackground: ViewModifier {
    var padded: Bool = true

    func body(content: Content) -> some View {
        content
            .padding(padded ? 16 : 0)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Theme.cardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Theme.cardStroke, lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle(padded: Bool = true) -> some View {
        modifier(CardBackground(padded: padded))
    }

    /// Applies the shared dungeon gradient behind a scrollable screen and
    /// strips the platform's default List/ScrollView chrome so the gradient
    /// shows through everywhere.
    func dungeonBackground() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Theme.backgroundGradient.ignoresSafeArea())
    }
}
