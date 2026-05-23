import SwiftUI

/// Animation tokens aligned with Figma motion notes (spring + ease).
enum AppAnimations {
    static let tagSpring = Animation.spring(response: 0.32, dampingFraction: 0.68)
    static let tabEase = Animation.easeInOut(duration: 0.22)
    static let cardSpring = Animation.spring(response: 0.45, dampingFraction: 0.82)
    static let barEase = Animation.easeOut(duration: 0.55)
    static let fabPulse = Animation.easeInOut(duration: 1.6).repeatForever(autoreverses: true)
    static let sheetSpring = Animation.spring(response: 0.42, dampingFraction: 0.86)
    static let popSpring = Animation.spring(response: 0.36, dampingFraction: 0.58)
    static let listSpring = Animation.spring(response: 0.4, dampingFraction: 0.78)
    static let pressSpring = Animation.spring(response: 0.26, dampingFraction: 0.64)
    static let staggerDelay: Double = 0.06

    static func motion(_ animation: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : animation
    }

    static var listInsert: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.92)).combined(with: .offset(y: 10)),
            removal: .opacity.combined(with: .scale(scale: 0.96))
        )
    }

    static var sheetPresent: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity.combined(with: .scale(scale: 0.98))
        )
    }

    static var screenSwap: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.97))
    }
}

// MARK: - Button press

struct ScalePressButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.94 : 1))
            .animation(AppAnimations.pressSpring, value: configuration.isPressed)
    }
}

// MARK: - Appear on load

struct AppearOnLoad: ViewModifier {
    @State private var visible = false
    let delay: Double
    /// When used inside a `TabView`, pass `page == index` so text appears when the page is shown.
    var isActive: Bool = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(y: visible ? 0 : (reduceMotion ? 0 : 14))
            .scaleEffect(visible ? 1 : (reduceMotion ? 1 : 0.96))
            .onAppear { revealIfNeeded() }
            .onChange(of: isActive) { active in
                if active { revealIfNeeded() }
            }
    }

    private func revealIfNeeded() {
        guard isActive, !visible else { return }
        if reduceMotion {
            visible = true
            return
        }
        withAnimation(AppAnimations.cardSpring.delay(delay)) {
            visible = true
        }
    }
}

struct StaggeredAppear: ViewModifier {
    let index: Int
    let baseDelay: Double
    @State private var visible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(visible ? 1 : 0)
            .offset(x: visible ? 0 : (reduceMotion ? 0 : -8))
            .onAppear {
                guard !reduceMotion else {
                    visible = true
                    return
                }
                withAnimation(AppAnimations.listSpring.delay(baseDelay + Double(index) * AppAnimations.staggerDelay)) {
                    visible = true
                }
            }
    }
}

struct BounceOnChangeModifier<V: Equatable>: ViewModifier {
    let value: V
    @State private var scale: CGFloat = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: value) { _ in
                performBounce()
            }
    }

    private func performBounce() {
        guard !reduceMotion else { return }
        scale = 1.1
        withAnimation(AppAnimations.popSpring) {
            scale = 1
        }
    }
}

/// Bounces only when this onboarding page becomes active.
struct OnboardingPageSymbol: View {
    let emoji: String
    let gradient: LinearGradient
    let pageIndex: Int
    let currentPage: Int

    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(emoji: String, gradient: LinearGradient, pageIndex: Int, currentPage: Int) {
        self.emoji = emoji
        self.gradient = gradient
        self.pageIndex = pageIndex
        self.currentPage = currentPage
        let active = currentPage == pageIndex
        _scale = State(initialValue: active ? 1 : 0.85)
        _opacity = State(initialValue: active ? 1 : 0)
    }

    var body: some View {
        Text(emoji)
            .font(.system(size: 72))
            .frame(width: 120, height: 120)
            .background(gradient, in: Circle())
            .shadow(color: AppTheme.primary.opacity(0.25), radius: 16, y: 8)
            .scaleEffect(scale)
            .opacity(opacity)
            .task(id: currentPage) {
                guard currentPage == pageIndex else { return }
                revealSymbol(animated: !reduceMotion)
            }
    }

    private func revealSymbol(animated: Bool) {
        if animated {
            withAnimation(AppAnimations.popSpring) {
                scale = 1
                opacity = 1
            }
        } else {
            scale = 1
            opacity = 1
        }
    }
}

struct SaveSuccessFlash: ViewModifier {
    @Binding var active: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(active && !reduceMotion ? 1.04 : 1)
            .animation(AppAnimations.popSpring, value: active)
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
    func appearOnLoad(delay: Double = 0, isActive: Bool = true) -> some View {
        modifier(AppearOnLoad(delay: delay, isActive: isActive))
    }

    func staggeredAppear(index: Int, baseDelay: Double = 0) -> some View {
        modifier(StaggeredAppear(index: index, baseDelay: baseDelay))
    }

    func bounceOnChange<V: Equatable>(value: V) -> some View {
        modifier(BounceOnChangeModifier(value: value))
    }

    func saveSuccessFlash(active: Binding<Bool>) -> some View {
        modifier(SaveSuccessFlash(active: active))
    }

    func scalePressStyle() -> some View {
        buttonStyle(ScalePressButtonStyle())
    }

    func animatedListBoundary<V: Equatable>(value: V) -> some View {
        animation(AppAnimations.listSpring, value: value)
    }
}
