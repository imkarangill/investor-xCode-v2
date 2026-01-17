//
//  ProgressBar.swift
//  Investor
//
//  Score progress bar component
//

import SwiftUI

struct ProgressBar: View {
    let value: Int
    let maxValue: Int
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                // Fill
                Rectangle()
                    .fill(color)
                    .frame(
                        width: max(0, geometry.size.width * progressRatio),
                        height: 8
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .frame(height: 8)
    }

    private var progressRatio: CGFloat {
        guard maxValue > 0 else { return 0 }
        return min(CGFloat(value) / CGFloat(maxValue), 1.0)
    }
}

// MARK: - Score Progress Bar (with label)

struct ScoreProgressBar: View {
    let label: String
    let value: Int
    let maxValue: Int

    var body: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Text(label)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)

            ProgressBar(
                value: value,
                maxValue: maxValue,
                color: ScoreColorUtil.color(forScore: value, maxScore: maxValue)
            )

            Text("\(value)/\(maxValue)")
                .font(AppTheme.Typography.caption)
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .trailing)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ProgressBar(value: 75, maxValue: 100, color: .green)

        ProgressBar(value: 45, maxValue: 100, color: .orange)

        ProgressBar(value: 20, maxValue: 100, color: .red)

        Divider()

        ScoreProgressBar(label: "Revenue", value: 22, maxValue: 29)
        ScoreProgressBar(label: "Op. Income", value: 18, maxValue: 29)
        ScoreProgressBar(label: "FCF", value: 8, maxValue: 29)
    }
    .padding()
}
