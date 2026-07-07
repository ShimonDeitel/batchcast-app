import SwiftUI

/// Batch Cast - Jewelry Casting Log's own palette: distinct from every sibling app in the portfolio.
enum BCTheme {
    static let backdrop = Color(red: 0.965, green: 0.957, blue: 0.933)
    static let card = Color.white

    static let ink = Color(red: 0.129, green: 0.114, blue: 0.086)
    static let inkFaded = Color(red: 0.129, green: 0.114, blue: 0.086).opacity(0.56)

    static let accent = Color(red: 0.678, green: 0.573, blue: 0.235)
    static let accentDeep = Color(red: 0.5980000000000001, green: 0.49299999999999994, blue: 0.15499999999999997)
    static let accent2 = Color(red: 0.204, green: 0.204, blue: 0.235)

    static let rule = Color.black.opacity(0.06)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let displayFont = Font.system(size: 40, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
}

struct BCDismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(BCDismissKeyboardOnTap())
    }
}

enum BCHaptics {
    static var enabled: Bool = true

    static func light() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
