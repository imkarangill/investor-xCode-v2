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

                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(item.symbol)
                            .font(AppTheme.Typography.caption2)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.top, AppTheme.Spacing.sm)
            
            if let score = item.score {
                HStack(spacing: AppTheme.Spacing.md) {
                    scoreProgressBar(score: score)
                    Text("\(score)")
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(scoreTextColor(score))
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.top, AppTheme.Spacing.xxs)
            }

            // Price
            Text(formatPrice(item.price, currency: item.currency))
                .font(AppTheme.Typography.title1)
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, AppTheme.Spacing.sm)

//            Divider().foregroundStyle(AppTheme.Colors.accent.opacity(0.2))

            // Price Changes Grid
            HStack(alignment: .top, spacing: 0) {
                priceChangeColumn("1D", item.priceChanges.d1)
                priceChangeColumn("1W", item.priceChanges.w1)
                priceChangeColumn("2W", item.priceChanges.w2)
                priceChangeColumn("1M", item.priceChanges.m1)
            }
            .padding(.top, AppTheme.Spacing.sm)
            
            if let earnings = item.earnings, let message = earnings.message {
                Text(message)
                    .font(AppTheme.Typography.caption2)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(AppTheme.Spacing.sm)
            }
        }
        .frame(width: 200, height: 220)
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

    private func scoreProgressBar(score: Int) -> some View {
        let fillPercentage = Double(score) / 100.0
        return GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(scoreBackgroundColor(score))

                RoundedRectangle(cornerRadius: 4)
                    .foregroundStyle(scoreTextColor(score))
                    .frame(width: geometry.size.width * fillPercentage)
            }
        }
        .frame(height: 4)
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
        priceChanges: PriceChanges(d1: "2.5", w1: "5.2", w2: "1.0", m1: "8.3"),
        earnings: EarningsNotification(message: "Earnings tomorrow")
    ))
    .padding()
}
