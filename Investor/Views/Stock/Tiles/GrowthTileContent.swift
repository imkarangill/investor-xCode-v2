//
//  GrowthTileContent.swift
//  Investor
//
//  Growth metrics tile content
//

import SwiftUI

struct GrowthTileContent: View {
    let growth: GrowthMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            GrowthTableHeader()

            Divider()

            // Revenue
            GrowthTableRow(label: "Revenue", metrics: growth.revenue)

            Divider()

            // Operating Income
            GrowthTableRow(label: "Op. Income", metrics: growth.operatingIncome)

            Divider()

            // Free Cash Flow
            GrowthTableRow(label: "FCF", metrics: growth.freeCashFlow)

            Divider()

            // Book Value
            GrowthTableRow(label: "Book Value", metrics: growth.bookValue)
        }
    }
}

// MARK: - Preview

#Preview {
    GrowthTileContent(
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
        )
    )
    .padding()
    .glassEffect()
    .padding()
}
