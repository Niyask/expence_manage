import SwiftUI

/// Animation tokens aligned with Figma motion notes (spring + ease).
enum AppAnimations {
    static let tagSpring = Animation.spring(response: 0.32, dampingFraction: 0.68)
    static let tabEase = Animation.easeInOut(duration: 0.22)
    static let cardSpring = Animation.spring(response: 0.45, dampingFraction: 0.82)
    static let barEase = Animation.easeOut(duration: 0.55)
    static let fabPulse = Animation.easeInOut(duration: 1.6).repeatForever(autoreverses: true)
    static let staggerDelay: Double = 0.06

    static func motion(_ animation: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : animation
    }
}

struct AppearOnLoad: ViewModifier {
    @State private var visible = false
    let delay: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : (reduceMotion ? 0 : 12))
            .onAppear {
                guard !reduceMotion else {
                    visible = true
                    return
                }
                withAnimation(AppAnimations.cardSpring.delay(delay)) {
                    visible = true
                }
            }
    }
}

struct AnimatedProgressBar: View {
    let progress: CGFloat
    let color: Color
    @State private var animatedProgress: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(red: 0.94, green: 0.95, blue: 0.96))
                Capsule()
                    .fill(color)
                    .frame(width: max(0, geo.size.width * min(1, animatedProgress)))
            }
        }
        .frame(height: 6)
        .onAppear { setProgress(progress) }
        .onChange(of: progress) { newValue in
            setProgress(newValue)
        }
    }

    private func setProgress(_ value: CGFloat) {
        let clamped = min(1, max(0, value))
        if reduceMotion {
            animatedProgress = clamped
        } else {
            withAnimation(AppAnimations.barEase) {
                animatedProgress = clamped
            }
        }
    }
}

extension View {
    func appearOnLoad(delay: Double = 0) -> some View {
        modifier(AppearOnLoad(delay: delay))
    }
}
