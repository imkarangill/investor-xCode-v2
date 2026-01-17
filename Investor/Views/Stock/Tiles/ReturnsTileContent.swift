//
//  ReturnsTileContent.swift
//  Investor
//
//  Returns metrics tile content (ROCE, FCFROCE)
//

import SwiftUI

struct ReturnsTileContent: View {
    let returns: ReturnsMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            GrowthTableHeader()

            Divider()

            // ROCE
            GrowthTableRow(label: "ROCE", metrics: returns.roce)

            Divider()

            // FCFROCE
            GrowthTableRow(label: "FCFROCE", metrics: returns.fcfroce)
        }
    }
}

// MARK: - Preview

#Preview {
    ReturnsTileContent(
        returns: ReturnsMetrics(
            roce: PeriodMetrics(
                fiveYear: 0.25,
                threeYear: 0.22,
                twoYear: 0.20,
                oneYear: 0.18,
                sixMonth: 0.15
            ),
            fcfroce: PeriodMetrics(
                fiveYear: 0.22,
                threeYear: 0.20,
                twoYear: 0.18,
                oneYear: 0.15,
                sixMonth: 0.12
            )
        )
    )
    .padding()
    .glassEffect()
    .padding()
}
