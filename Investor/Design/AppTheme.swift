//
//  AppTheme.swift
//  Investor
//
//  Created for xCode-v2 rewrite
//  Design system with typography, spacing, and colors
//

import SwiftUI

struct AppTheme {
    // MARK: - Colors

    struct Colors {
        // Semantic colors for financial data
        static let positive = Color.green
        static let negative = Color.red
        static let neutral = Color.secondary

        // Text colors
        static let primaryText = Color.primary
        static let secondaryText = Color.secondary

        // Accent
        static let accent = Color.accentColor

        // Backgrounds (SwiftUI adaptive colors - work on all platforms)
        static let primaryBackground = Color(.sRGBLinear, red: 0.95, green: 0.95, blue: 0.98, opacity: 1)
        static let secondaryBackground = Color(.sRGBLinear, red: 0.92, green: 0.92, blue: 0.96, opacity: 1)
    }

    // MARK: - Typography

    struct Typography {
        // Display fonts
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.medium)

        // Body fonts
        static let body = Font.body
        static let bodyEmphasized = Font.body.weight(.medium)
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2

        // Monospaced for financial data
        static let monospaced = Font.system(.body, design: .monospaced)
        static let monospacedLarge = Font.system(.title3, design: .monospaced).weight(.medium)
    }

    // MARK: - Spacing

    struct Spacing {
        static let xxxs: CGFloat = 2
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    // MARK: - Corner Radius

    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }

    // MARK: - Animation

    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
    }

    // MARK: - Legal

    struct Legal {
        static let financialDisclaimer = "This information is provided for educational and informational purposes only and does not constitute financial, investment, legal, or tax advice. The data and metrics presented are based on historical financial statements and do not guarantee future performance. You should consult with a qualified financial advisor before making any investment decisions. Past performance is not indicative of future results."
    }
}

// MARK: - Score Color Utility

struct ScoreColorUtil {
    static func color(forScore score: Int, maxScore: Int) -> Color {
        guard maxScore > 0 else { return .gray }
        let percentage = Double(score) / Double(maxScore)

        switch percentage {
        case 0.7...1.0:
            return .green
        case 0.4..<0.7:
            return .orange
        default:
            return .red
        }
    }
}

// MARK: - View Extensions for Glass Effects (iOS 26+)

extension View {
    /// Applies native Liquid Glass effect (iOS 26+)
    func glassEffect(in shape: some InsettableShape = .rect(cornerRadius: AppTheme.CornerRadius.md)) -> some View {
        self
            .background {
                shape
                    .fill(.regularMaterial)
            }
            .clipShape(shape)
    }

    /// Applies glass effect for buttons
    func glassButtonStyle(isSelected: Bool = false) -> some View {
        self
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .background {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md)
                    .fill(isSelected ? .regularMaterial : .ultraThinMaterial)
            }
    }
}
