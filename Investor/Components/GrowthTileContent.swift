//
//  GrowthTileContent.swift
//  Investor
//
//  Growth metrics tile content
//

import SwiftUI

struct GrowthTileContent: View {
    let overview: StockOverview

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            GrowthTableHeader()

            Divider()

            // Revenue
            GrowthTableRow(label: "Revenue", metrics: overview.growth.revenue)

            Divider()

            // Operating Income
            GrowthTableRow(label: "Op. Income", metrics: overview.growth.operatingIncome)

            Divider()

            // Free Cash Flow
            GrowthTableRow(label: "FCF", metrics: overview.growth.freeCashFlow)

            Divider()

            // Book Value
            GrowthTableRow(label: "Book Value", metrics: overview.growth.bookValue)
        }
    }
}

// MARK: - Preview

#Preview {
    GrowthTileContent(
        overview: StockOverview(
            symbol: "AAPL",
            lastUpdated: nil,
            profile: StockProfile(
                symbol: "AAPL",
                companyName: "Apple Inc.",
                price: 150.0,
                changes: 2.5,
                changePercentage: 1.7,
                mktCap: 2_300_000_000_000,
                calculatedMktCap: nil,
                volume: 50_000_000,
                volAvg: 52_000_000,
                beta: 1.2,
                range: "$140-$155",
                lastDiv: 0.23,
                currency: "USD",
                exchange: "NASDAQ",
                industry: "Technology",
                sector: "Technology",
                ceo: "Tim Cook",
                description: nil,
                website: "https://apple.com",
                employees: "164000",
                image: nil
            ),
            score: StockScore(
                overall: 75,
                maxScore: 100,
                breakdown: ScoreBreakdown(
                    revenue: 8, operatingIncome: 7, freeCashFlow: 9, bookValue: 6,
                    roce: 8, fcfroce: 7, profitMargin: 8, debtEquity: 7,
                    liabilityEquity: 6, currentRatio: 7, quickRatio: 6
                )
            ),
            growth: GrowthMetrics(
                revenue: PeriodMetrics(
                    fiveYear: 0.15,
                    threeYear: 0.12,
                    twoYear: 0.10,
                    oneYear: 0.08,
                    sixMonth: 0.05
                ),
                operatingIncome: PeriodMetrics(
                    fiveYear: 0.18,
                    threeYear: 0.15,
                    twoYear: 0.12,
                    oneYear: 0.10,
                    sixMonth: -0.02
                ),
                freeCashFlow: PeriodMetrics(
                    fiveYear: 0.20,
                    threeYear: 0.18,
                    twoYear: 0.15,
                    oneYear: 0.12,
                    sixMonth: 0.08
                ),
                bookValue: PeriodMetrics(
                    fiveYear: 0.10,
                    threeYear: 0.08,
                    twoYear: 0.06,
                    oneYear: 0.05,
                    sixMonth: 0.03
                )
            ),
            returns: ReturnsMetrics(
                roce: PeriodMetrics(fiveYear: 0.15, threeYear: 0.13, twoYear: 0.11, oneYear: 0.09, sixMonth: 0.05),
                fcfroce: PeriodMetrics(fiveYear: 0.18, threeYear: 0.16, twoYear: 0.14, oneYear: 0.12, sixMonth: 0.08)
            ),
            ratios: Ratios(
                profitMargin: PeriodMetrics(fiveYear: 0.25, threeYear: 0.26, twoYear: 0.27, oneYear: 0.28, sixMonth: 0.29),
                debtToEquity: PeriodMetrics(fiveYear: 0.30, threeYear: 0.32, twoYear: 0.35, oneYear: 0.38, sixMonth: 0.40),
                liabilityToEquity: PeriodMetrics(fiveYear: 0.45, threeYear: 0.48, twoYear: 0.50, oneYear: 0.52, sixMonth: 0.55),
                currentRatio: PeriodMetrics(fiveYear: 1.5, threeYear: 1.6, twoYear: 1.7, oneYear: 1.8, sixMonth: 1.9),
                quickRatio: PeriodMetrics(fiveYear: 1.2, threeYear: 1.25, twoYear: 1.3, oneYear: 1.35, sixMonth: 1.4)
            ),
            valuation: nil,
            earnings: [],
            dividends: [],
            analystRatings: nil,
            momentum: nil,
            prices: nil,
            _metadata: nil
        )
    )
    .padding()
    .glassEffect()
    .padding()
}
