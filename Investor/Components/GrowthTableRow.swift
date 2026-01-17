//
//  GrowthTableRow.swift
//  Investor
//
//  Table row for displaying period metrics (growth/returns/ratios)
//

import SwiftUI

struct GrowthTableRow: View {
    let label: String
    let metrics: PeriodMetrics
    let formatAsPercentage: Bool

    init(label: String, metrics: PeriodMetrics, formatAsPercentage: Bool = true) {
        self.label = label
        self.metrics = metrics
        self.formatAsPercentage = formatAsPercentage
    }

    var body: some View {
        HStack(spacing: 0) {
            // Label
            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.primary)
                .frame(width: 100, alignment: .leading)

            // Values
            ForEach(Array(metrics.allValues.enumerated()), id: \.offset) { _, value in
                Text(formattedValue(value))
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(colorForValue(value))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, AppTheme.Spacing.xxs)
    }

    private func formattedValue(_ value: Double?) -> String {
        guard let value = value else { return "—" }

        if formatAsPercentage {
            return String(format: "%.0f%%", value * 100)
        } else {
            return String(format: "%.2f", value)
        }
    }

    private func colorForValue(_ value: Double?) -> Color {
        guard let value = value else { return .secondary }

        if formatAsPercentage {
            return value >= 0 ? AppTheme.Colors.positive : AppTheme.Colors.negative
        } else {
            // For ratios, interpretation depends on the metric
            return .primary
        }
    }
}

// MARK: - Growth Table Header

struct GrowthTableHeader: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("")
                .frame(width: 100, alignment: .leading)

            ForEach(PeriodMetrics.periodLabels, id: \.self) { period in
                Text(period)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, AppTheme.Spacing.xxs)
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 0) {
        GrowthTableHeader()

        Divider()

        GrowthTableRow(
            label: "Revenue",
            metrics: PeriodMetrics(
                fiveYear: 0.15,
                threeYear: 0.12,
                twoYear: 0.10,
                oneYear: 0.08,
                sixMonth: -0.02
            )
        )

        Divider()

        GrowthTableRow(
            label: "Op. Income",
            metrics: PeriodMetrics(
                fiveYear: 0.20,
                threeYear: 0.18,
                twoYear: 0.15,
                oneYear: 0.12,
                sixMonth: 0.05
            )
        )

        Divider()

        GrowthTableRow(
            label: "Debt/Equity",
            metrics: PeriodMetrics(
                fiveYear: 0.45,
                threeYear: 0.50,
                twoYear: 0.55,
                oneYear: 0.60,
                sixMonth: 0.65
            ),
            formatAsPercentage: false
        )
    }
    .padding()
}
