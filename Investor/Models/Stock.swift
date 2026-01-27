//
//  Stock.swift
//  Investor
//
//  Data models matching investor-api-service responses
//

import Foundation

// MARK: - Period Metrics

struct PeriodMetrics: Codable, Equatable, Sendable {
    let fiveYear: Double?
    let threeYear: Double?
    let twoYear: Double?
    let oneYear: Double?
    let sixMonth: Double?

    enum CodingKeys: String, CodingKey {
        case fiveYear = "5y"
        case threeYear = "3y"
        case twoYear = "2y"
        case oneYear = "1y"
        case sixMonth = "6m"
    }

    /// Returns an array of values in order: [5y, 3y, 2y, 1y, 6m]
    var allValues: [Double?] {
        [fiveYear, threeYear, twoYear, oneYear, sixMonth]
    }

    static let periodLabels = ["5y", "3y", "2y", "1y", "6m"]
}

// MARK: - Stock List Item

struct StockListItem: Codable, Identifiable, Equatable, Sendable {
    let symbol: String
    let companyName: String?
    let currency: String?
    let exchange: String?
    let industry: String?
    let sector: String?
    let country: String?
    let image: String?
    let isEtf: Bool?
    let isActivelyTrading: Bool?
    let isAdr: Bool?
    let isFund: Bool?

    var id: String { symbol }
}

// MARK: - Stock Profile

struct StockProfile: Codable, Sendable {
    let symbol: String
    let companyName: String?
    let price: Double?
    let changes: Double?
    let changePercentage: Double?
    let mktCap: Int64?
    let calculatedMktCap: Int64?
    let volume: Int64?
    let volAvg: Int64?
    let beta: Double?
    let range: String?
    let lastDiv: Double?
    let currency: String?
    let exchange: String?
    let industry: String?
    let sector: String?
    let ceo: String?
    let description: String?
    let website: String?
    let employees: String?
    let image: String?
}

// MARK: - Score Breakdown

struct ScoreBreakdown: Codable, Sendable {
    let revenue: Int
    let operatingIncome: Int
    let freeCashFlow: Int
    let bookValue: Int
    let roce: Int
    let fcfroce: Int
    let profitMargin: Int
    let debtEquity: Int
    let liabilityEquity: Int
    let currentRatio: Int
    let quickRatio: Int
}

// MARK: - Score

struct StockScore: Codable, Sendable {
    let overall: Int
    let maxScore: Int
    let breakdown: ScoreBreakdown
}

// MARK: - Growth Metrics

struct GrowthMetrics: Codable, Sendable {
    let revenue: PeriodMetrics
    let operatingIncome: PeriodMetrics
    let freeCashFlow: PeriodMetrics
    let bookValue: PeriodMetrics
}

// MARK: - Returns Metrics

struct ReturnsMetrics: Codable, Sendable {
    let roce: PeriodMetrics
    let fcfroce: PeriodMetrics
}

// MARK: - Ratios

struct Ratios: Codable, Sendable {
    let profitMargin: PeriodMetrics
    let debtToEquity: PeriodMetrics
    let liabilityToEquity: PeriodMetrics
    let currentRatio: PeriodMetrics
    let quickRatio: PeriodMetrics
}

// MARK: - Momentum

struct Momentum: Codable, Sendable {
    let score: Double
    let signal: String
    let strength: String
    let date: String
    let calculatedAt: String
}

// MARK: - Earnings

struct Earnings: Codable, Identifiable, Sendable {
    let date: String
    let epsActual: Double?
    let epsEstimated: Double?
    let revenueActual: Int64?
    let revenueEstimated: Int64?

    var id: String { date }
}

// MARK: - Dividend

struct Dividend: Codable, Identifiable, Sendable {
    let date: String
    let amount: Double?
    let recordDate: String?
    let paymentDate: String?
    let yield: Double?

    var id: String { date }
}

// MARK: - Stock Overview Response

struct StockOverview: Codable, Identifiable, Sendable {
    let symbol: String
    let lastUpdated: String?
    let profile: StockProfile
    let score: StockScore
    let growth: GrowthMetrics
    let returns: ReturnsMetrics
    let ratios: Ratios
    let valuation: [String: [String: Double?]]?
    let earnings: [Earnings]
    let dividends: [Dividend]
    let analystRatings: [String: Double]?
    let momentum: Momentum?
    let prices: [String: PricePoint]?
    let _metadata: APIMetadata?

    var id: String { symbol }
}

// MARK: - Price Point

struct PricePoint: Codable, Sendable {
    let price: Double
    let date: String
}

// MARK: - API Metadata

struct APIMetadata: Codable, Sendable {
    let calculationsPerformed: Int?
    let cacheEnabled: Bool?
    let cacheTTL: Int?
    let maxScore: Int?
}

// MARK: - API Error

struct APIError: Codable, Sendable {
    let error: String
}

// MARK: - Scoring Algorithm Constants

enum ScoringAlgorithm {
    /// Maximum total score: 4x29 (growth) + 2x8 (returns) + 5x10 (ratios) = 182
    static let maxTotalScore = 182

    /// Maximum score per growth metric (Revenue, Operating Income, FCF, Book Value)
    static let maxGrowthMetricScore = 29

    /// Maximum score per return metric (ROCE, FCFROCE)
    static let maxReturnMetricScore = 8

    /// Maximum score per ratio metric (PM, D/E, L/E, CR, QR)
    static let maxRatioMetricScore = 10
}
