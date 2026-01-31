//
//  StockHeader.swift
//  Investor
//
//  Header component displaying stock profile information
//

import SwiftUI
import Charts

struct StockHeader: View {
    let overview: StockOverview
    @State private var expanded = false

    var body: some View {
            VStack() {
            Button(action: {
                if expanded == false {
                    expanded.toggle()
                }
            }) {
                
                VStack() {
                    
                    if expanded {
                        Button(action: { expanded.toggle() }) {
                            Text("Close")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(AppTheme.Spacing.xs)
                            
                        }
                        .glassEffect(.regular, in: .capsule)
                        
                    }
                    
                    // Company Logo, name and price
                    HStack() {
                        StockLogoImage(imageUrl: overview.profile.image, symbol: overview.symbol, size: 50)
                        
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                            if let companyName = overview.profile.companyName {
                                Text(companyName)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                            }
                            Text(overview.symbol)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        VStack() {
                            if let price = overview.profile.price {
                                Text(StockService.formatPrice(price, currency: overview.profile.currency))
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if expanded {

                        // if today is ipo birthday, show special message
                        if let ipoDate = overview.profile.ipoDate, let years = getIPOAnniversaryYears(ipoDate) {
                            HStack(spacing: AppTheme.Spacing.xs) {
                                Text("🎉")
                                Text("IPO Anniversary - \(years) \(years == 1 ? "year" : "years")!")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text("🎉")
                            }
                            .foregroundStyle(.secondary)
                            .padding(.vertical, AppTheme.Spacing.sm)
                            //.frame(maxWidth: .infinity)
                            //.glassEffect(.regular, in: .capsule)
                        }

                        Divider().padding(.vertical, AppTheme.Spacing.sm)
                        ScrollView {
                            PriceChart(historicalPrice: overview.historicalPrice)
                                .frame(height: 200)
                            
                            // Additional Details
                            VStack(alignment: .leading) {
                                
                                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                                    if let sector = overview.profile.sector {
                                        DetailItem(label: "Sector", value: sector)
                                    }
                                    if let industry = overview.profile.industry {
                                        DetailItem(label: "Industry", value: industry)
                                    }
                                    if let ceo = overview.profile.ceo {
                                        DetailItem(label: "CEO", value: ceo)
                                    }
                                    if let employees = overview.profile.employees {
                                        DetailItem(label: "Employees", value: employees)
                                    }
                                    if let website = overview.profile.website, let url = URL(string: website.hasPrefix("http") ? website : "https://\(website)") {
                                        VStack(alignment: .leading) {
                                            Text("Website")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            Link(website, destination: url)
                                                .font(.caption)
                                                .foregroundStyle(.blue)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    if let ipoDate = overview.profile.ipoDate {
                                        DetailItem(label: "IPO Date", value: formatIPODate(ipoDate))
                                    }
                                    if let description = overview.profile.description {
                                        DetailItem(label: "About", value: description)
                                    }
                                }
                            }
                            .padding(.top, AppTheme.Spacing.md)
                        }
                        .frame(maxHeight: 500)

                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(AppTheme.Spacing.md)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 20))
            
            if expanded == false {
                StockTabs().padding(.bottom)
            }
            }
        }

}

// MARK: - Helper Components

struct PriceChart: View {
    // Data structure for price points
    struct PricePoint: Identifiable {
        let id = UUID()
        let date: String
        let displayLabel: String
        let price: Double
    }

    let historicalPrice: [String: [String: Double]]?
    @State private var selectedPeriod = "1Y"

    let periods = ["1D", "1W", "1M", "3M", "6M", "1Y", "3Y", "5Y"]

    func formatLabel(dateString: String, period: String) -> String {
        if period == "1D" && dateString.contains("T") {
            // Time only: "2026-01-30T09:30:00Z" -> "09:30"
            let timeComponent = dateString.split(separator: "T").dropFirst().first ?? ""
            return String(timeComponent.prefix(5))
        } else if period == "1W" {
            // Day of week and date: "2026-01-30" -> "Thu 01-30"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: dateString) {
                formatter.dateFormat = "EEE MM-dd"
                return formatter.string(from: date)
            }
            return String(dateString.dropFirst(5).prefix(5))
        } else if period == "1M" {
            // Date: "2026-01-30" -> "01-30"
            return String(dateString.dropFirst(5).prefix(5))
        } else {
            // Longer periods: "2026-01-30" -> "Jan 30"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: dateString) {
                formatter.dateFormat = period == "1Y" ? "MMM dd" : "MMM 'yy"
                return formatter.string(from: date)
            }
            return String(dateString.dropFirst(5).prefix(5))
        }
    }

    var chartData: [PricePoint] {
        guard let historicalPrice = historicalPrice,
              let periodData = historicalPrice[selectedPeriod] else {
            return []
        }

        return periodData
            .sorted { $0.key < $1.key }
            .map { dateString, price in
                let displayLabel = formatLabel(dateString: dateString, period: selectedPeriod)
                return PricePoint(date: dateString, displayLabel: displayLabel, price: price)
            }
    }

    var axisLabelDates: [String] {
        guard chartData.count > 0 else { return [] }
        let step = max(1, chartData.count / 5)
        var labels: [String] = []
        for i in stride(from: 0, to: chartData.count, by: step) {
            labels.append(chartData[i].displayLabel)
        }
        if let last = chartData.last?.displayLabel, !labels.contains(last) {
            labels.append(last)
        }
        return labels
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: AppTheme.Spacing.md) {

            // Chart
            if chartData.isEmpty {
                Text("No price data available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 150)
            } else {
                Chart(chartData) { point in
                    LineMark(
                        x: .value("Date", point.displayLabel),
                        y: .value("Price", point.price)
                    )
                    .foregroundStyle(.blue)
                }
                .chartYAxis {
                    AxisMarks(position: .trailing) { _ in
                        AxisValueLabel()
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom, values: axisLabelDates) { _ in
                        AxisValueLabel()
                    }
                }
                .frame(height: 150)
            }
            
            // Period Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(periods, id: \.self) { period in
                        Button(action: { selectedPeriod = period }) {
                            Text(period)
                                .font(.caption)
                                .foregroundStyle(selectedPeriod == period ? .blue : .secondary)
                                .padding(.horizontal, AppTheme.Spacing.sm)
                                .padding(.vertical, 6)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.md)
            }
        }
        .padding()
    }
}

struct DetailItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.caption)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
            image: "https://images.financialmodelingprep.com/symbol/AAPL.png",
            ipoDate: "1980-12-12"
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
        historicalPrice: [
            "o": [
                "2000-01-03": 100.52,
                "2001-02-15": 102.18,
                "2002-03-20": 98.75,
                "2003-04-10": 105.42,
                "2004-05-18": 112.65,
                "2005-06-22": 118.32,
                "2006-07-30": 125.48,
                "2007-08-12": 132.15,
                "2008-09-25": 128.95,
                "2009-10-14": 138.22,
                "2010-11-03": 145.75,
                "2011-12-20": 152.48,
                "2012-01-15": 158.32,
                "2013-02-28": 165.95,
                "2014-03-14": 172.18,
                "2015-04-22": 178.45,
                "2016-05-10": 185.62,
                "2017-06-18": 192.35,
                "2018-07-25": 198.72,
                "2019-08-05": 205.48,
                "2020-09-12": 212.15,
                "2021-10-20": 218.92,
                "2022-11-08": 224.35,
                "2023-12-15": 228.95,
                "2024-01-20": 230.15,
                "2025-02-10": 227.82,
                "2026-01-30": 228.65
            ],
            "5Y": [
                "2021-01-04": 130.73,
                "2021-02-08": 138.55,
                "2021-03-15": 145.32,
                "2021-04-22": 152.18,
                "2021-05-30": 158.95,
                "2021-06-14": 165.42,
                "2021-07-20": 172.35,
                "2021-08-25": 178.92,
                "2021-09-10": 185.48,
                "2021-10-18": 192.15,
                "2021-11-22": 198.72,
                "2021-12-30": 205.35,
                "2022-01-15": 210.48,
                "2022-02-20": 215.32,
                "2022-03-28": 218.95,
                "2022-04-10": 220.15,
                "2022-05-18": 219.82,
                "2022-06-25": 218.45,
                "2022-07-30": 215.95,
                "2022-08-12": 212.35,
                "2022-09-20": 210.48,
                "2022-10-28": 208.95,
                "2022-11-15": 210.32,
                "2022-12-22": 215.48,
                "2023-01-20": 220.35,
                "2023-02-28": 225.18,
                "2023-03-15": 228.95,
                "2023-04-22": 230.15,
                "2023-05-30": 228.82,
                "2023-06-14": 228.65,
                "2023-07-20": 228.92,
                "2023-08-25": 229.35,
                "2023-09-10": 229.72,
                "2023-10-18": 230.15,
                "2023-11-22": 230.48,
                "2023-12-30": 230.95,
                "2024-01-15": 231.32,
                "2024-02-20": 231.95,
                "2024-03-28": 232.35,
                "2024-04-10": 232.82,
                "2024-05-18": 232.48,
                "2024-06-25": 232.15,
                "2024-07-30": 231.82,
                "2024-08-12": 231.35,
                "2024-09-20": 230.95,
                "2024-10-28": 230.48,
                "2024-11-15": 230.15,
                "2024-12-22": 229.82,
                "2025-01-20": 229.35,
                "2025-02-28": 228.95,
                "2025-03-15": 228.65,
                "2025-04-22": 228.82,
                "2025-05-30": 229.15,
                "2025-06-14": 229.48,
                "2025-07-20": 229.82,
                "2025-08-25": 229.95,
                "2025-09-10": 230.18,
                "2025-10-18": 230.35,
                "2025-11-22": 230.48,
                "2025-12-30": 228.95,
                "2026-01-30": 228.65
            ],
            "3Y": [
                "2023-01-31": 150.93,
                "2023-02-15": 155.28,
                "2023-03-10": 160.45,
                "2023-04-12": 165.73,
                "2023-05-18": 170.92,
                "2023-06-22": 175.35,
                "2023-07-28": 179.48,
                "2023-08-15": 183.92,
                "2023-09-20": 188.15,
                "2023-10-25": 192.45,
                "2023-11-30": 196.82,
                "2023-12-20": 200.35,
                "2024-01-10": 202.95,
                "2024-02-15": 205.48,
                "2024-03-20": 208.15,
                "2024-04-25": 210.82,
                "2024-05-22": 213.35,
                "2024-06-18": 215.48,
                "2024-07-25": 217.92,
                "2024-08-20": 219.35,
                "2024-09-18": 220.95,
                "2024-10-22": 222.18,
                "2024-11-20": 223.45,
                "2024-12-18": 224.95,
                "2025-01-15": 225.82,
                "2025-02-20": 226.45,
                "2025-03-18": 227.35,
                "2025-04-22": 228.15,
                "2025-05-20": 228.82,
                "2025-06-25": 229.35,
                "2025-07-22": 229.95,
                "2025-08-20": 230.28,
                "2025-09-18": 230.62,
                "2025-10-22": 230.95,
                "2025-11-20": 229.82,
                "2025-12-18": 229.35,
                "2026-01-30": 228.65
            ],
            "1Y": [
                "2025-01-31": 192.48,
                "2025-02-14": 194.82,
                "2025-03-14": 197.35,
                "2025-04-10": 200.18,
                "2025-05-15": 203.45,
                "2025-06-20": 206.82,
                "2025-07-18": 210.15,
                "2025-08-22": 213.35,
                "2025-09-19": 216.45,
                "2025-10-17": 219.82,
                "2025-11-21": 223.15,
                "2025-12-19": 226.48,
                "2026-01-09": 227.95,
                "2026-01-23": 228.35,
                "2026-01-30": 228.65
            ],
            "6M": [
                "2025-07-31": 212.35,
                "2025-08-15": 214.82,
                "2025-09-10": 217.35,
                "2025-10-15": 220.15,
                "2025-11-20": 223.45,
                "2025-12-20": 225.82,
                "2026-01-09": 227.35,
                "2026-01-23": 228.15,
                "2026-01-30": 228.65
            ],
            "3M": [
                "2025-10-31": 218.92,
                "2025-11-14": 221.35,
                "2025-12-10": 224.18,
                "2026-01-09": 226.82,
                "2026-01-23": 227.95,
                "2026-01-30": 228.65
            ],
            "1M": [
                "2025-12-31": 224.35,
                "2026-01-08": 226.15,
                "2026-01-15": 227.45,
                "2026-01-23": 228.25,
                "2026-01-30": 228.65
            ],
            "1W": [
                "2026-01-24": 227.85,
                "2026-01-27": 228.15,
                "2026-01-30": 228.65
            ],
            "1D": [
                "2026-01-30T09:30:00Z": 226.50,
                "2026-01-30T10:00:00Z": 226.50,
                "2026-01-30T10:30:00Z": 226.50,
                "2026-01-30T11:00:00Z": 226.50,
                "2026-01-30T11:30:00Z": 226.50,
                "2026-01-30T12:00:00Z": 226.50,
                "2026-01-30T12:30:00Z": 226.50,
                "2026-01-30T13:00:00Z": 226.50,
                "2026-01-30T13:30:00Z": 226.50,
                "2026-01-30T14:00:00Z": 226.50,
                "2026-01-30T14:30:00Z": 226.50,
                "2026-01-30T15:00:00Z": 226.50,
                "2026-01-30T15:30:00Z": 226.50
            ]
        ],
        _metadata: nil
    ))
    .padding()
}
