//
//  StockTileCard.swift
//  Investor
//
//  Reusable card component for displaying stock information
//

import SwiftUI

struct StockTileCard: View {
    let item: RecentlyViewedItem

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                StockLogoImage(imageUrl: item.image, symbol: item.symbol, size: 36)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text(item.symbol)
                        .font(AppTheme.Typography.caption2)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Text(item.companyName)
                        .font(AppTheme.Typography.callout)
                        .lineLimit(1)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                }
            }

            HStack {
                Text(formatPrice(item.price, currency: item.currency))
                    .font(AppTheme.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                Spacer()

                scoreBadge(item.score)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                priceChangeRow("1D", item.priceChanges.d1)
                priceChangeRow("1W", item.priceChanges.w1)
                priceChangeRow("2W", item.priceChanges.w2)
                priceChangeRow("1M", item.priceChanges.m1)
            }
        }
        .padding(AppTheme.Spacing.md)
        .frame(width: 180)
        .glassEffect(.regular.interactive(), in: .containerRelative)
    }

    // MARK: - Helpers

    private func priceChangeRow(_ label: String, _ value: String?) -> some View {
        HStack {
            Text(label)
                .font(AppTheme.Typography.caption2)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            Spacer()

            if let valueStr = value, let doubleValue = Double(valueStr) {
                let color = doubleValue >= 0 ? AppTheme.Colors.positive : AppTheme.Colors.negative
                Text(formatPercentage(doubleValue))
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(color)
            } else {
                Text("—")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
    }

    private func formatPercentage(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return String(format: "%@%.2f%%", sign, value)
    }

    private func formatPrice(_ priceStr: String, currency: String) -> String {
        guard let price = Double(priceStr) else { return "—" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: price)) ?? "—"
    }

    private func scoreBadge(_ score: Int) -> some View {
        let backgroundColor: Color
        if score >= 70 {
            backgroundColor = .green.opacity(0.2)
        } else if score >= 50 {
            backgroundColor = .orange.opacity(0.2)
        } else {
            backgroundColor = .red.opacity(0.2)
        }

        let textColor: Color
        if score >= 70 {
            textColor = .green
        } else if score >= 50 {
            textColor = .orange
        } else {
            textColor = .red
        }

        return Text("\(score)")
            .font(AppTheme.Typography.callout)
            .fontWeight(.semibold)
            .foregroundStyle(textColor)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.xxs)
            .background(backgroundColor)
            .clipShape(Capsule())
    }
}

#Preview {
    StockTileCard(item: RecentlyViewedItem(
        symbol: "AAPL",
        companyName: "Apple Inc.",
        image: "https://images.financialmodelingprep.com/symbol/AAPL.png",
        currency: "USD",
        price: "273.45",
        score: 85,
        priceChanges: PriceChanges(d1: "2.5", w1: "5.2", w2: "1.0", m1: "8.3")
    ))
    .padding()
}
