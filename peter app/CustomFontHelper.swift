import SwiftUI

// MARK: - Custom Typography & Font Modifiers
struct VolleyballCustomTitle: ViewModifier {
    var size: CGFloat = 20
    var weight: Font.Weight = .bold
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight, design: .rounded))
            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

extension View {
    func customVolleyballTitle(size: CGFloat = 20, weight: Font.Weight = .bold) -> some View {
        self.modifier(VolleyballCustomTitle(size: size, weight: weight))
    }
}
