import SwiftUI

// MARK: - Flowbar Animations
struct FlowbarAnimations {

    // MARK: - Mode Switching Animation
    static func modeSwitchAnimation() -> Animation {
        .easeInOut(duration: 0.3)
    }

    // MARK: - Icon Fade Animation
    static func iconFadeAnimation() -> Animation {
        .easeOut(duration: 0.2)
    }

    // MARK: - Transition Animations
    static var defaultTransition: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.95))
    }

    static var slideTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    // MARK: - Spring Animations
    static func springAnimation() -> Animation {
        .spring(response: 0.3, dampingFraction: 0.7)
    }

    static func bouncySpringAnimation() -> Animation {
        .spring(response: 0.4, dampingFraction: 0.5)
    }

    // MARK: - Custom View Modifiers
    struct AnimatedScale: ViewModifier {
        @State private var isScaled: Bool = false

        func body(content: Content) -> some View {
            content
                .scaleEffect(isScaled ? 1.0 : 0.9)
                .onAppear {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isScaled = true
                    }
                }
        }
    }

    struct AnimatedFadeIn: ViewModifier {
        @State private var opacity: Double = 0

        func body(content: Content) -> some View {
            content
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 1.0
                    }
                }
        }
    }

    struct AnimatedSlideIn: ViewModifier {
        @State private var offset: CGFloat = 20
        @State private var opacity: Double = 0

        func body(content: Content) -> some View {
            content
                .offset(y: offset)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.3)) {
                        offset = 0
                        opacity = 1.0
                    }
                }
        }
    }
}

// MARK: - View Extensions
extension View {
    func animatedScale() -> some View {
        modifier(FlowbarAnimations.AnimatedScale())
    }

    func animatedFadeIn() -> some View {
        modifier(FlowbarAnimations.AnimatedFadeIn())
    }

    func animatedSlideIn() -> some View {
        modifier(FlowbarAnimations.AnimatedSlideIn())
    }

    func withDefaultTransition() -> some View {
        transition(FlowbarAnimations.defaultTransition)
    }

    func withSlideTransition() -> some View {
        transition(FlowbarAnimations.slideTransition)
    }
}

// MARK: - Mode Switch Transition Modifier
struct ModeSwitchTransitionModifier: ViewModifier {
    let isActive: Bool

    @State private var isAnimating: Bool = false

    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 1.0 : 0.7)
            .scaleEffect(isAnimating ? 1.0 : 0.98)
            .animation(FlowbarAnimations.modeSwitchAnimation(), value: isAnimating)
            .onChange(of: isActive) { _, _ in
                isAnimating = false
                withAnimation(FlowbarAnimations.modeSwitchAnimation()) {
                    isAnimating = true
                }
            }
            .onAppear {
                isAnimating = true
            }
    }
}

extension View {
    func modeSwitchTransition(isActive: Bool) -> some View {
        modifier(ModeSwitchTransitionModifier(isActive: isActive))
    }
}

// MARK: - Icon Visibility Transition
struct IconVisibilityTransition: ViewModifier {
    let isVisible: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1.0 : 0.0)
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .animation(FlowbarAnimations.iconFadeAnimation(), value: isVisible)
    }
}

extension View {
    func iconVisibilityTransition(isVisible: Bool) -> some View {
        modifier(IconVisibilityTransition(isVisible: isVisible))
    }
}

// MARK: - Progress Animation
struct ProgressAnimation: ViewModifier {
    let progress: Double

    @State private var animatedProgress: Double = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    ZStack {
                        Capsule()
                            .fill(Color.accentColor)
                            .frame(width: geometry.size.width * animatedProgress)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .allowsHitTesting(false)
            )
            .onChange(of: progress) { _, newValue in
                withAnimation(.easeInOut(duration: 0.3)) {
                    animatedProgress = newValue
                }
            }
            .onAppear {
                animatedProgress = progress
            }
    }
}

extension View {
    func progressAnimation(progress: Double) -> some View {
        modifier(ProgressAnimation(progress: progress))
    }
}

// MARK: - Hover Effect Modifier
struct HoverEffectModifier: ViewModifier {
    @State private var isHovering: Bool = false

    let scaleEffect: CGFloat
    let brightnessEffect: Double

    init(scale: CGFloat = 1.05, brightness: Double = 0.1) {
        self.scaleEffect = scale
        self.brightnessEffect = brightness
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovering ? scaleEffect : 1.0)
            .brightness(isHovering ? brightnessEffect : 0.0)
            .animation(.easeInOut(duration: 0.2), value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

extension View {
    func hoverEffect(scale: CGFloat = 1.05, brightness: Double = 0.1) -> some View {
        modifier(HoverEffectModifier(scale: scale, brightness: brightness))
    }
}

// MARK: - Ripple Effect Modifier
struct RippleEffectModifier: ViewModifier {
    @State private var isRippling: Bool = false

    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .scaleEffect(isRippling ? 1.5 : 0)
                    .opacity(isRippling ? 0 : 1)
                    .animation(.easeOut(duration: 0.5), value: isRippling)
            )
            .onTapGesture {
                isRippling = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isRippling = false
                }
            }
    }
}

extension View {
    func rippleEffect() -> some View {
        modifier(RippleEffectModifier())
    }
}

// MARK: - Breathing Animation Modifier
struct BreathingAnimationModifier: ViewModifier {
    @State private var isExpanded: Bool = false

    let scaleRange: ClosedRange<Double>
    let duration: Double

    init(scale: ClosedRange<Double> = 0.95...1.0, duration: Double = 2.0) {
        self.scaleRange = scale
        self.duration = duration
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(isExpanded ? scaleRange.upperBound : scaleRange.lowerBound)
            .animation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true),
                value: isExpanded
            )
            .onAppear {
                isExpanded = true
            }
    }
}

extension View {
    func breathingAnimation(scale: ClosedRange<Double> = 0.95...1.0, duration: Double = 2.0) -> some View {
        modifier(BreathingAnimationModifier(scale: scale, duration: duration))
    }
}

// MARK: - Shimmer Effect Modifier
struct ShimmerEffectModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.3),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width)
                    .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                }
            )
            .animation(
                .linear(duration: 1.5)
                    .repeatForever(autoreverses: false),
                value: phase
            )
            .onAppear {
                phase = 1
            }
            .clipped()
    }
}

extension View {
    func shimmerEffect() -> some View {
        modifier(ShimmerEffectModifier())
    }
}

// MARK: - Notification Banner Animation
struct NotificationBannerModifier: ViewModifier {
    @State private var offset: CGFloat = -100
    @State private var opacity: Double = 0
    let isPresented: Bool

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .shadow(radius: 10)
                    .frame(height: 60)
                    .overlay(
                        Text("Notification")
                            .font(.body)
                    )
                    .offset(y: offset)
                    .opacity(opacity)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: offset)
                    .animation(.easeOut(duration: 0.2), value: opacity)
                    .onAppear {
                        offset = 0
                        opacity = 1
                    }
            }
        }
    }
}

extension View {
    func notificationBanner(isPresented: Bool) -> some View {
        modifier(NotificationBannerModifier(isPresented: isPresented))
    }
}

// MARK: - Dark/Light Mode Adaptive Animation
struct AdaptiveAppearanceModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .animation(.easeInOut(duration: 0.3), value: colorScheme)
    }
}

extension View {
    func adaptiveAppearance() -> some View {
        modifier(AdaptiveAppearanceModifier())
    }
}
