//
//  HomeView.swift
//  Investor
//
//  Home screen with portfolio, watchlists, recently viewed
//

import SwiftUI

struct HomeView: View {
    @StateObject private var homeService = HomeService()
    @Binding var currentView: String
    @Binding var selectedStock: String?

    var body: some View {
        ZStack {
            if homeService.isLoading && homeService.homeData == nil {
                loadingView
            } else if let error = homeService.error, homeService.homeData == nil {
                errorView
            } else if let homeData = homeService.homeData {
                ScrollView {
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Portfolio Section
                        portfolioSection(homeData.portfolio)

                        // Watchlists Section
                        watchlistsSection(homeData.watchlists)

                        // Recently Viewed Section
                        recentlyViewedSection(homeData.recentlyViewed)

                        // Market Overview Section (placeholder)
                        marketOverviewSection()

                        Spacer(minLength: AppTheme.Spacing.xl)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.md)
                }
                .refreshable {
                    await homeService.fetchHome()
                }
            } else {
                emptyView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.primaryBackground)
        .task {
            await homeService.fetchHome()
        }
    }

    // MARK: - Sections

    private func portfolioSection(_ portfolio: [PortfolioItem]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            if !portfolio.isEmpty {
                Text("Portfolio")
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .padding(.horizontal, AppTheme.Spacing.xs)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.md) {
                        ForEach(portfolio) { item in
                            portfolioCard(item)
                                .onTapGesture {
                                    selectedStock = item.symbol
                                    currentView = "stock"
                                }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xs)
                }
            }
        }
    }

    private func portfolioCard(_ item: PortfolioItem) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            HStack(spacing: AppTheme.Spacing.sm) {
                StockLogoImage(imageUrl: item.image, symbol: item.symbol, size: 36)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text(item.symbol)
                            .font(AppTheme.Typography.caption2)
                            .foregroundStyle(AppTheme.Colors.secondaryText)

                        if let earnings = item.earnings, let message = earnings.message {
                            Text(message)
                                .font(AppTheme.Typography.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppTheme.Spacing.xs)
                                .padding(.vertical, 2)
                                .background(AppTheme.Colors.accent)
                                .clipShape(Capsule())
                        }
                    }

                    Text(item.companyName)
                        .font(AppTheme.Typography.callout)
                        .lineLimit(1)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                }

                Spacer()

                scoreBadge(item.score)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                HStack {
                    Text("Qty:")
                        .font(AppTheme.Typography.caption2)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                    Text(item.quantity)
                        .font(AppTheme.Typography.caption2)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                }

                HStack {
                    Text("Value:")
                        .font(AppTheme.Typography.caption2)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                    Text("\(item.value) \(item.currency)")
                        .font(AppTheme.Typography.caption2)
                        .foregroundStyle(AppTheme.Colors.primaryText)
                }
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                priceChangeRow("D1:", item.priceChanges.d1)
                priceChangeRow("W1:", item.priceChanges.w1)
                priceChangeRow("W2:", item.priceChanges.w2)
                priceChangeRow("M1:", item.priceChanges.m1)
            }
        }
        .padding(AppTheme.Spacing.md)
        .frame(width: 200)
        .glassEffect()
    }

    private func watchlistsSection(_ watchlists: [Watchlist]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            if !watchlists.isEmpty {
                Text("Watchlists")
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .padding(.horizontal, AppTheme.Spacing.xs)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.md) {
                        ForEach(watchlists) { watchlist in
                            watchlistCard(watchlist)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xs)
                }
            }
        }
    }

    private func watchlistCard(_ watchlist: Watchlist) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                HStack {
                    Text(watchlist.name)
                        .font(AppTheme.Typography.callout)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    if watchlist.isDefault {
                        Text("Default")
                            .font(AppTheme.Typography.caption2)
                            .padding(.horizontal, AppTheme.Spacing.xs)
                            .padding(.vertical, AppTheme.Spacing.xxs)
                            .background(AppTheme.Colors.accent.opacity(0.2))
                            .foregroundStyle(AppTheme.Colors.accent)
                            .clipShape(Capsule())
                    }

                    Spacer()
                }

                Text("\(watchlist.totalStocks) stocks")
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }

            if !watchlist.stocks.isEmpty {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                    ForEach(watchlist.stocks.prefix(3)) { stock in
                        watchlistStockRow(stock)
                            .onTapGesture {
                                selectedStock = stock.symbol
                                currentView = "stock"
                            }
                    }
                }
            }
        }
        .padding(AppTheme.Spacing.md)
        .frame(width: 200)
        .glassEffect()
    }

    private func watchlistStockRow(_ stock: WatchlistStock) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            StockLogoImage(imageUrl: stock.image, symbol: stock.symbol, size: 28)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                HStack(spacing: AppTheme.Spacing.xs) {
                    Text(stock.symbol)
                        .font(AppTheme.Typography.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    if let earnings = stock.earnings, let message = earnings.message {
                        Text(message)
                            .font(AppTheme.Typography.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppTheme.Spacing.xs)
                            .padding(.vertical, 2)
                            .background(AppTheme.Colors.accent)
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: AppTheme.Spacing.xxs) {
                    if let changeStr = stock.priceChanges.d1, let change = Double(changeStr) {
                        let color = change >= 0 ? AppTheme.Colors.positive : AppTheme.Colors.negative
                        Text(formatPercentage(change))
                            .font(AppTheme.Typography.caption2)
                            .foregroundStyle(color)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: AppTheme.Spacing.xxs) {
                scoreBadge(stock.score, size: .small)

                Text(formatPrice(stock.price))
                    .font(AppTheme.Typography.caption2)
                    .foregroundStyle(AppTheme.Colors.primaryText)
            }
        }
    }

    private func recentlyViewedSection(_ recentlyViewed: [RecentlyViewedItem]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            if !recentlyViewed.isEmpty {
                Text("Recently Viewed")
                    .font(AppTheme.Typography.title2)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .padding(.horizontal, AppTheme.Spacing.xs)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.Spacing.md) {
                        ForEach(recentlyViewed) { item in
                            StockTileCard(item: item)
                                .onTapGesture {
                                    selectedStock = item.symbol
                                    currentView = "stock"
                                }
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.xs)
                }
            }
        }
    }

    private func marketOverviewSection() -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text("Market Overview")
                .font(AppTheme.Typography.title2)
                .foregroundStyle(AppTheme.Colors.primaryText)
                .padding(.horizontal, AppTheme.Spacing.xs)

            VStack(alignment: .center, spacing: AppTheme.Spacing.md) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 40))
                    .foregroundStyle(AppTheme.Colors.accent.opacity(0.5))

                Text("Market Overview Coming Soon")
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                Text("Get updates on major indices and market trends")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.lg)
            .glassEffect()
        }
    }

    // MARK: - Loading & Error States

    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Loading your portfolio...")
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.primaryBackground)
    }

    private var errorView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.red)

            Text("Unable to Load Portfolio")
                .font(AppTheme.Typography.title2)
                .foregroundStyle(AppTheme.Colors.primaryText)

            if let error = homeService.error {
                Text(error.localizedDescription)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppTheme.Spacing.md)
            }

            Button {
                Task {
                    await homeService.fetchHome()
                }
            } label: {
                Text("Retry")
                    .font(AppTheme.Typography.callout)
                    .fontWeight(.semibold)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(AppTheme.Colors.accent)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.primaryBackground)
    }

    private var emptyView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: "briefcase")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.Colors.accent.opacity(0.5))

            Text("No Portfolio Yet")
                .font(AppTheme.Typography.title2)
                .foregroundStyle(AppTheme.Colors.primaryText)

            Text("Start building your portfolio by searching for stocks")
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.primaryBackground)
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

}

#Preview {
    @State var currentView = "home"
    @State var selectedStock: String? = nil

    return ZStack {
        HomeView(currentView: $currentView, selectedStock: $selectedStock)
    }
}
