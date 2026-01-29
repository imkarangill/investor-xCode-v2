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
        VStack(alignment: .leading, spacing: 0) {
            // Header: Image + Symbol/Name
            HStack(spacing: AppTheme.Spacing.sm) {
                StockLogoImage(imageUrl: item.image, symbol: item.symbol, size: 44)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    Text(item.companyName)
                        .font(AppTheme.Typography.callout)
                        .lineLimit(1)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                    
                    Text(item.symbol)
                        .font(AppTheme.Typography.caption2)
                        .foregroundStyle(AppTheme.Colors.secondaryText)


                }
            }
            .padding(AppTheme.Spacing.sm)
            
            HStack(spacing: AppTheme.Spacing.sm) {
                scoreProgressBar
                Text("\(item.score)")
                    .font(AppTheme.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(scoreColor)
            }
            .padding(AppTheme.Spacing.sm)

            // Price
            Text(formatPrice(item.price, currency: item.currency))
                .font(AppTheme.Typography.title1)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(AppTheme.Spacing.sm)

//            Divider().foregroundStyle(AppTheme.Colors.accent.opacity(0.2))

            // Price Changes Grid
            HStack(alignment: .top, spacing: 0) {
                priceChangeColumn("1D", item.priceChanges.d1)
                priceChangeColumn("1W", item.priceChanges.w1)
                priceChangeColumn("2W", item.priceChanges.w2)
                priceChangeColumn("1M", item.priceChanges.m1)
            }
            .padding(AppTheme.Spacing.sm)
        }
        .frame(width: 200)
        .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
        .padding(AppTheme.Spacing.sm)
    }

    // MARK: - Helpers

    private func priceChangeColumn(_ label: String, _ value: String?) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            Text(label)
                .font(AppTheme.Typography.caption2)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            if let valueStr = value, let doubleValue = Double(valueStr) {
                let color = doubleValue >= 0 ? AppTheme.Colors.positive : AppTheme.Colors.negative
                Text(formatPercentage(doubleValue))
                    .font(AppTheme.Typography.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            } else {
                Text("—")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var scoreColor: Color {
        if item.score >= 70 {
            return .green
        } else if item.score >= 50 {
            return .orange
        } else {
            return .red
        }
    }

    private var scoreBackgroundColor: Color {
        if item.score >= 70 {
            return .green.opacity(0.2)
        } else if item.score >= 50 {
            return .orange.opacity(0.2)
        } else {
            return .red.opacity(0.2)
        }
    }

    private var scoreProgressBar: some View {
        let fillPercentage = Double(item.score) / 100.0
        return GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(scoreBackgroundColor)

                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(scoreColor)
                    .frame(width: geometry.size.width * fillPercentage)
            }
        }
        .frame(height: 4)
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
