//
//  Home.swift
//  Investor
//
//  Data models for /api/v1/users/me/home endpoint
//

import Foundation

// MARK: - Price Changes

struct PriceChanges: Codable, Sendable {
    let d1: String?      // 1-day change percentage
    let w1: String?      // 1-week change percentage
    let w2: String?      // 2-week change percentage
    let m1: String?      // 1-month change percentage
}

// MARK: - Earnings Notification

struct EarningsNotification: Codable, Sendable {
    let message: String?
}

// MARK: - Portfolio Item

struct PortfolioItem: Codable, Identifiable, Sendable {
    let symbol: String
    let companyName: String
    let image: String?
    let currency: String
    let quantity: String
    let value: String
    let price: String
    let score: Int?
    let priceChanges: PriceChanges
    let earnings: EarningsNotification?

    var id: String { symbol }

    enum CodingKeys: String, CodingKey {
        case symbol
        case companyName = "company_name"
        case image
        case currency
        case quantity
        case value
        case price
        case score
        case priceChanges = "price_changes"
        case earnings
    }
}

// MARK: - Watchlist Stock

struct WatchlistStock: Codable, Identifiable, Sendable {
    let symbol: String
    let companyName: String
    let image: String?
    let price: String
    let score: Int?
    let priceChanges: PriceChanges
    let earnings: EarningsNotification?

    var id: String { symbol }

    enum CodingKeys: String, CodingKey {
        case symbol
        case companyName = "company_name"
        case image
        case price
        case score
        case priceChanges = "price_changes"
        case earnings
    }
}

// MARK: - Watchlist

struct Watchlist: Codable, Identifiable, Sendable {
    let id: String
    let name: String
    let isDefault: Bool
    let totalStocks: Int
    let stocks: [WatchlistStock]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isDefault = "is_default"
        case totalStocks = "total_stocks"
        case stocks
    }
}

// MARK: - Recently Viewed Item

struct RecentlyViewedItem: Codable, Identifiable, Sendable {
    let symbol: String
    let companyName: String
    let image: String?
    let currency: String
    let price: String
    let score: Int?
    let priceChanges: PriceChanges
    let earnings: EarningsNotification?

    var id: String { symbol }

    enum CodingKeys: String, CodingKey {
        case symbol
        case companyName = "company_name"
        case image
        case currency
        case price
        case score
        case priceChanges = "price_changes"
        case earnings
    }
}

// MARK: - Market Overview (placeholder for future expansion)

struct MarketOverview: Codable, Sendable {
    let placeholder: String?  // Currently null, for future expansion
}

// MARK: - Home Response (Root)

struct HomeResponse: Codable, Sendable {
    let portfolio: [PortfolioItem]
    let watchlists: [Watchlist]
    let recentlyViewed: [RecentlyViewedItem]
    let marketOverview: MarketOverview?

    enum CodingKeys: String, CodingKey {
        case portfolio
        case watchlists
        case recentlyViewed = "recently_viewed"
        case marketOverview = "market_overview"
    }
}
