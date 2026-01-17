//
//  RatiosTileContent.swift
//  Investor
//
//  Financial ratios tile content
//

import SwiftUI

struct RatiosTileContent: View {
    let ratios: Ratios

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            GrowthTableHeader()

            Divider()

            // Profit Margin
            GrowthTableRow(label: "Profit Margin", metrics: ratios.profitMargin)

            Divider()

            // Debt/Equity
            GrowthTableRow(label: "Debt/Equity", metrics: ratios.debtToEquity, formatAsPercentage: false)

            Divider()

            // Liability/Equity
            GrowthTableRow(label: "Liab./Equity", metrics: ratios.liabilityToEquity, formatAsPercentage: false)

            Divider()

            // Current Ratio
            GrowthTableRow(label: "Current Ratio", metrics: ratios.currentRatio, formatAsPercentage: false)

            Divider()

            // Quick Ratio
            GrowthTableRow(label: "Quick Ratio", metrics: ratios.quickRatio, formatAsPercentage: false)
        }
    }
}

// MARK: - Preview

#Preview {
    RatiosTileContent(
        ratios: Ratios(
            profitMargin: PeriodMetrics(
                fiveYear: 0.25,
                threeYear: 0.24,
                twoYear: 0.23,
                oneYear: 0.22,
                sixMonth: 0.21
            ),
            debtToEquity: PeriodMetrics(
                fiveYear: 0.50,
                threeYear: 0.55,
                twoYear: 0.60,
                oneYear: 0.65,
                sixMonth: 0.70
            ),
            liabilityToEquity: PeriodMetrics(
                fiveYear: 1.20,
                threeYear: 1.25,
                twoYear: 1.30,
                oneYear: 1.35,
                sixMonth: 1.40
            ),
            currentRatio: PeriodMetrics(
                fiveYear: 2.50,
                threeYear: 2.40,
                twoYear: 2.30,
                oneYear: 2.20,
                sixMonth: 2.10
            ),
            quickRatio: PeriodMetrics(
                fiveYear: 1.80,
                threeYear: 1.70,
                twoYear: 1.60,
                oneYear: 1.50,
                sixMonth: 1.40
            )
        )
    )
    .padding()
    .glassEffect()
    .padding()
}
