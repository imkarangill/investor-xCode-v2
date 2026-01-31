//
//  Helper.swift
//  Investor
//
//  Created by Karan Gill on 1/24/26.
//

import SwiftUI

// MARK: - Country Helpers

func flagEmoji(_ countryCode: String) -> String {
    let base: UInt32 = 127397
    return countryCode
        .uppercased()
        .unicodeScalars
        .compactMap { UnicodeScalar(base + $0.value) }
        .map { String($0) }
        .joined()
}

// MARK: - Score Badge Helpers

enum BadgeSize {
    case small
    case normal
}

func scoreTextColor(_ score: Int) -> Color {
    if score >= 70 {
        return .green
    } else if score >= 50 {
        return .orange
    } else {
        return .red
    }
}

func scoreBackgroundColor(_ score: Int) -> Color {
    if score >= 70 {
        return .green.opacity(0.2)
    } else if score >= 50 {
        return .orange.opacity(0.2)
    } else {
        return .red.opacity(0.2)
    }
}

@ViewBuilder
func scoreBadge(_ score: Int?, size: BadgeSize = .normal) -> some View {
    if let score = score {
        let (fontSize, padding) = size == .small ?
            (AppTheme.Typography.caption2, AppTheme.Spacing.xs) :
            (AppTheme.Typography.callout, AppTheme.Spacing.sm)

        Text("\(score)")
            .font(fontSize)
            .fontWeight(.semibold)
            .foregroundStyle(scoreTextColor(score))
            .padding(.horizontal, padding)
            .padding(.vertical, AppTheme.Spacing.xxs)
            .background(scoreBackgroundColor(score))
            .clipShape(Capsule())
    } else {
        Text("N/A")
            .font(AppTheme.Typography.caption2)
            .foregroundStyle(AppTheme.Colors.secondaryText)
            .padding(.horizontal, AppTheme.Spacing.xs)
            .padding(.vertical, AppTheme.Spacing.xxs)
            .background(AppTheme.Colors.secondaryText.opacity(0.1))
            .clipShape(Capsule())
    }
}

// MARK: - Formatting Helpers

func formatPercentage(_ value: Double) -> String {
    //let sign = value >= 0 ? "+" : ""
    return String(format: "%.1f%%", value)
}

func formatPrice(_ priceStr: String, currency: String = "USD") -> String {
    guard let price = Double(priceStr) else { return "—" }
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: price)) ?? "—"
}
