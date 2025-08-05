import SwiftUI

struct AppFonts {
    // MARK: - Font Families
    static let primaryFamily = "SF Pro Display"
    static let secondaryFamily = "SF Pro Text"
    static let monoFamily = "SF Mono"
    
    // MARK: - Display Fonts (Large Headings)
    static let largeTitle = Font.custom(primaryFamily, size: 34, relativeTo: .largeTitle).weight(.bold)
    static let title1 = Font.custom(primaryFamily, size: 28, relativeTo: .title).weight(.bold)
    static let title2 = Font.custom(primaryFamily, size: 22, relativeTo: .title2).weight(.bold)
    static let title3 = Font.custom(primaryFamily, size: 20, relativeTo: .title3).weight(.semibold)
    
    // MARK: - Headline Fonts
    static let headline = Font.custom(secondaryFamily, size: 17, relativeTo: .headline).weight(.semibold)
    static let subheadline = Font.custom(secondaryFamily, size: 15, relativeTo: .subheadline).weight(.medium)
    
    // MARK: - Body Fonts
    static let body = Font.custom(secondaryFamily, size: 17, relativeTo: .body).weight(.regular)
    static let bodyMedium = Font.custom(secondaryFamily, size: 17, relativeTo: .body).weight(.medium)
    static let bodyBold = Font.custom(secondaryFamily, size: 17, relativeTo: .body).weight(.bold)
    
    // MARK: - Secondary Text
    static let callout = Font.custom(secondaryFamily, size: 16, relativeTo: .callout).weight(.regular)
    static let footnote = Font.custom(secondaryFamily, size: 13, relativeTo: .footnote).weight(.regular)
    static let caption1 = Font.custom(secondaryFamily, size: 12, relativeTo: .caption).weight(.regular)
    static let caption2 = Font.custom(secondaryFamily, size: 11, relativeTo: .caption2).weight(.regular)
    
    // MARK: - Button Fonts
    static let buttonLarge = Font.custom(secondaryFamily, size: 17, relativeTo: .body).weight(.semibold)
    static let buttonMedium = Font.custom(secondaryFamily, size: 15, relativeTo: .subheadline).weight(.semibold)
    static let buttonSmall = Font.custom(secondaryFamily, size: 13, relativeTo: .footnote).weight(.semibold)
    
    // MARK: - Navigation Fonts
    static let navigationTitle = Font.custom(primaryFamily, size: 20, relativeTo: .title3).weight(.bold)
    static let navigationSubtitle = Font.custom(secondaryFamily, size: 13, relativeTo: .footnote).weight(.medium)
    
    // MARK: - Card Fonts
    static let cardTitle = Font.custom(secondaryFamily, size: 16, relativeTo: .callout).weight(.semibold)
    static let cardSubtitle = Font.custom(secondaryFamily, size: 14, relativeTo: .footnote).weight(.medium)
    static let cardDescription = Font.custom(secondaryFamily, size: 13, relativeTo: .footnote).weight(.regular)
    
    // MARK: - Form Fonts
    static let formLabel = Font.custom(secondaryFamily, size: 15, relativeTo: .subheadline).weight(.medium)
    static let formField = Font.custom(secondaryFamily, size: 16, relativeTo: .callout).weight(.regular)
    static let formHelper = Font.custom(secondaryFamily, size: 12, relativeTo: .caption).weight(.regular)
    
    // MARK: - Tab Bar Fonts
    static let tabTitle = Font.custom(secondaryFamily, size: 10, relativeTo: .caption2).weight(.medium)
    
    // MARK: - Monospace Fonts (for numbers, codes)
    static let monoLarge = Font.custom(monoFamily, size: 16, relativeTo: .callout).weight(.medium)
    static let monoMedium = Font.custom(monoFamily, size: 14, relativeTo: .footnote).weight(.medium)
    static let monoSmall = Font.custom(monoFamily, size: 12, relativeTo: .caption).weight(.medium)
    
    // MARK: - Special Use Cases
    static let onboardingTitle = Font.custom(primaryFamily, size: 32, relativeTo: .largeTitle).weight(.bold)
    static let onboardingSubtitle = Font.custom(secondaryFamily, size: 18, relativeTo: .title3).weight(.medium)
    
    static let dashboardTitle = Font.custom(primaryFamily, size: 24, relativeTo: .title2).weight(.bold)
    static let dashboardMetric = Font.custom(monoFamily, size: 20, relativeTo: .title3).weight(.bold)
    
    static let taskTitle = Font.custom(secondaryFamily, size: 16, relativeTo: .callout).weight(.semibold)
    static let taskDescription = Font.custom(secondaryFamily, size: 14, relativeTo: .footnote).weight(.regular)
    
    static let projectTitle = Font.custom(secondaryFamily, size: 18, relativeTo: .title3).weight(.bold)
    static let projectDescription = Font.custom(secondaryFamily, size: 15, relativeTo: .subheadline).weight(.regular)
    
    // MARK: - Accessibility Support
    static func scaledFont(_ font: Font, maxSize: CGFloat = 30) -> Font {
        return font
    }
    
    // MARK: - Dynamic Type Support
    static func adaptiveFont(baseSize: CGFloat, weight: Font.Weight = .regular, family: String = secondaryFamily) -> Font {
        return Font.custom(family, size: baseSize, relativeTo: .body).weight(weight)
    }
}

// MARK: - Text Style Modifiers

struct TitleTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFonts.title1)
            .foregroundColor(.textPrimary)
    }
}

struct HeadlineTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFonts.headline)
            .foregroundColor(.textPrimary)
    }
}

struct BodyTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFonts.body)
            .foregroundColor(.textSecondary)
    }
}

struct CaptionTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFonts.caption1)
            .foregroundColor(.textTertiary)
    }
}

struct AccentTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(AppFonts.bodyMedium)
            .foregroundColor(.textAccent)
    }
}

// MARK: - View Extensions

extension View {
    func titleTextStyle() -> some View {
        modifier(TitleTextStyle())
    }
    
    func headlineTextStyle() -> some View {
        modifier(HeadlineTextStyle())
    }
    
    func bodyTextStyle() -> some View {
        modifier(BodyTextStyle())
    }
    
    func captionTextStyle() -> some View {
        modifier(CaptionTextStyle())
    }
    
    func accentTextStyle() -> some View {
        modifier(AccentTextStyle())
    }
}