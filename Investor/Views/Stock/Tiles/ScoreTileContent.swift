//
//  ScoreTileContent.swift
//  Investor
//
//  Score breakdown tile content
//

import SwiftUI

struct ScoreTileContent: View {
    let score: StockScore

    @AppStorage("scoreTile.showGrowthMetrics") private var showGrowthMetrics = true
    @AppStorage("scoreTile.showReturnMetrics") private var showReturnMetrics = false
    @AppStorage("scoreTile.showRatioMetrics") private var showRatioMetrics = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Interpretation
            Text(scoreInterpretation)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, AppTheme.Spacing.sm)

            // Growth section
            CategoryHeader(title: "Growth", isExpanded: $showGrowthMetrics)

            if showGrowthMetrics {
                Divider()
                ScoreProgressBar(
                    label: "Revenue",
                    value: score.breakdown.revenue,
                    maxValue: ScoringAlgorithm.maxGrowthMetricScore
                )
                Divider()
                ScoreProgressBar(
                    label: "Op. Income",
                    value: score.breakdown.operatingIncome,
                    maxValue: ScoringAlgorithm.maxGrowthMetricScore
                )
                Divider()
                ScoreProgressBar(
                    label: "FCF",
                    value: score.breakdown.freeCashFlow,
                    maxValue: ScoringAlgorithm.maxGrowthMetricScore
                )
                Divider()
                ScoreProgressBar(
                    label: "Book Value",
                    value: score.breakdown.bookValue,
                    maxValue: ScoringAlgorithm.maxGrowthMetricScore
                )
            }

            Divider()

            // Returns section
            CategoryHeader(title: "Returns", isExpanded: $showReturnMetrics)

            if showReturnMetrics {
                Divider()
                ScoreProgressBar(
                    label: "ROCE",
                    value: score.breakdown.roce,
                    maxValue: ScoringAlgorithm.maxReturnMetricScore
                )
                Divider()
                ScoreProgressBar(
                    label: "FCFROCE",
                    value: score.breakdown.fcfroce,
                    maxValue: ScoringAlgorithm.maxReturnMetricScore
                )
            }

            Divider()

            // Ratios section
            CategoryHeader(title: "Ratios", isExpanded: $showRatioMetrics)

            if showRatioMetrics {
                Divider()
                ScoreProgressBar(
                    label: "Profit Margin",
                    value: score.breakdown.profitMargin,
                    maxValue: ScoringAlgorithm.maxRatioMetricScore
                )
                Divider()
                ScoreProgressBar(
                    label: "Debt/Equity",
                    value: score.breakdown.debtEquity,
                    maxValue: ScoringAlgorithm.maxRatioMetricScore
                )
                Divider()
                ScoreProgressBar(
                    label: "Liability/Equity",
                    value: score.breakdown.liabilityEquity,
                    maxValue: ScoringAlgorithm.maxRatioMetricScore
                )
                Divider()
                ScoreProgressBar(
                    label: "Current Ratio",
                    value: score.breakdown.currentRatio,
                    maxValue: ScoringAlgorithm.maxRatioMetricScore
                )
                Divider()
                ScoreProgressBar(
                    label: "Quick Ratio",
                    value: score.breakdown.quickRatio,
                    maxValue: ScoringAlgorithm.maxRatioMetricScore
                )
            }
        }
    }

    // MARK: - Score Interpretation

    private var scoreInterpretation: String {
        let percentage = Double(score.overall) / Double(score.maxScore)

        switch percentage {
        case 0.9...1.0:
            return "Exceptional and consistent growth across all metrics."
        case 0.7..<0.9:
            return "Strong, stable compounder with minor slowdowns."
        case 0.5..<0.7:
            return "Moderate or mixed growth; cyclical or uneven performance."
        default:
            return "Weak or volatile growth, recent deterioration visible."
        }
    }
}

// MARK: - Preview

#Preview {
    ScoreTileContent(
        score: StockScore(
            overall: 145,
            maxScore: 182,
            breakdown: ScoreBreakdown(
                revenue: 22,
                operatingIncome: 20,
                freeCashFlow: 18,
                bookValue: 15,
                roce: 6,
                fcfroce: 5,
                profitMargin: 8,
                debtEquity: 7,
                liabilityEquity: 6,
                currentRatio: 7,
                quickRatio: 6
            )
        )
    )
    .padding()
    .glassEffect()
    .padding()
}
