//
//  StockHeader.swift
//  Investor
//
//  Header component displaying stock profile information
//

import SwiftUI

struct StockHeader: View {
    let overview: StockOverview

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Company Logo and Basic Info
            HStack(alignment: .top, spacing: 12) {
                StockLogoImage(imageUrl: overview.profile.image, symbol: overview.symbol, size: 50)

                VStack(alignment: .leading, spacing: 2) {
                    if let companyName = overview.profile.companyName {
                        Text(companyName)
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    Text(overview.symbol)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let price = overview.profile.price {
                    Text(StockService.formatPrice(price, currency: overview.profile.currency))
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }

//            // Company Details - Two Column Layout
//            VStack(alignment: .leading, spacing: 8) {
//                HStack(spacing: 16) {
//                    // Left column
//                    VStack(alignment: .leading, spacing: 8) {
//                        if let sector = overview.profile.sector {
//                            DetailItem(label: "Sector", value: sector)
//                        }
//                        if let industry = overview.profile.industry {
//                            DetailItem(label: "Industry", value: industry)
//                        }
//                    }
//
//                    Spacer()
//
//                    // Right column
//                    VStack(alignment: .leading, spacing: 8) {
//                        if let employees = overview.profile.employees {
//                            DetailItem(label: "Employees", value: employees)
//                        }
//                        DetailItem(label: "Market Cap", value: StockService.formatMarketCap(overview.profile.calculatedMktCap))
//                    }
//                }
//
//                if let website = overview.profile.website {
//                    DetailItem(label: "Website", value: website)
//                }
//            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        .glassEffect(.regular.interactive(), in: .containerRelative)
    }
}

// MARK: - Helper Components

struct DetailItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.callout)
        }
    }
}

#Preview {
    StockHeader(overview: StockOverview(
        symbol: "AAPL",
        lastUpdated: "2026-01-04T20:07:54.716864+00:00",
        profile: StockProfile(
            symbol: "AAPL",
            companyName: "Apple Inc.",
            price: 273.4,
            changes: 2.5,
            changePercentage: 0.92,
            mktCap: nil,
            calculatedMktCap: 4086919899999,
            volume: nil,
            volAvg: nil,
            beta: 1.107,
            range: "169.21-288.62",
            lastDiv: nil,
            currency: "USD",
            exchange: "NASDAQ",
            industry: "Consumer Electronics",
            sector: "Technology",
            ceo: "Timothy D. Cook",
            description: "Apple Inc. designs, manufactures, and markets smartphones...",
            website: "https://www.apple.com",
            employees: "164000",
            image: "https://images.financialmodelingprep.com/symbol/AAPL.png"
        ),
        score: StockScore(
            overall: 99,
            maxScore: 182,
            breakdown: ScoreBreakdown(
                revenue: 27,
                operatingIncome: 26,
                freeCashFlow: 7,
                bookValue: 27,
                roce: 8,
                fcfroce: 8,
                profitMargin: 10,
                debtEquity: -2,
                liabilityEquity: -3,
                currentRatio: -5,
                quickRatio: -4
            )
        ),
        growth: GrowthMetrics(
            revenue: PeriodMetrics(fiveYear: 0.1206, threeYear: 0.0464, twoYear: 0.0684, oneYear: 0.0903, sixMonth: 0.0505),
            operatingIncome: PeriodMetrics(fiveYear: 0.1853, threeYear: 0.0654, twoYear: 0.1063, oneYear: 0.1062, sixMonth: 0.0557),
            freeCashFlow: PeriodMetrics(fiveYear: 0.0943, threeYear: -0.0128, twoYear: 0.0211, oneYear: -0.0701, sixMonth: 0.0135),
            bookValue: PeriodMetrics(fiveYear: 0.0535, threeYear: 0.1605, twoYear: 0.1132, oneYear: 0.3152, sixMonth: 0.1076)
        ),
        returns: ReturnsMetrics(
            roce: PeriodMetrics(fiveYear: 0.3034, threeYear: 0.6009, twoYear: 0.5514, oneYear: 0.6534, sixMonth: 0.6823),
            fcfroce: PeriodMetrics(fiveYear: 0.3358, threeYear: 0.5607, twoYear: 0.4804, oneYear: 0.577, sixMonth: 0.5276)
        ),
        ratios: Ratios(
            profitMargin: PeriodMetrics(fiveYear: 0.2091, threeYear: 0.2531, twoYear: 0.2531, oneYear: 0.2397, sixMonth: 0.243),
            debtToEquity: PeriodMetrics(fiveYear: 1.0, threeYear: 2.0, twoYear: 1.0, oneYear: 2.0, sixMonth: 1.0),
            liabilityToEquity: PeriodMetrics(fiveYear: 3.0, threeYear: 5.0, twoYear: 4.0, oneYear: 5.0, sixMonth: 3.0),
            currentRatio: PeriodMetrics(fiveYear: 1.0, threeYear: 0.0, twoYear: 0.0, oneYear: 0.0, sixMonth: 0.0),
            quickRatio: PeriodMetrics(fiveYear: 1.0, threeYear: 0.0, twoYear: 0.0, oneYear: 0.0, sixMonth: 0.0)
        ),
        valuation: nil,
        earnings: [],
        dividends: [],
        analystRatings: nil,
        momentum: nil,
        prices: nil,
        _metadata: nil
    ))
    .padding()
}
