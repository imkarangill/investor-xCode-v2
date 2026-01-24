//
//  StockOverviewView.swift
//  Investor
//
//  Stock overview screen
//

import SwiftUI

struct StockOverviewView: View {
    @ObservedObject var service: StockService
    let symbol: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if service.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                        Text("Loading \(symbol)...")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else if let error = service.error {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundStyle(.red)
                        Text("Error")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else if let overview = service.stockOverview {
                    // Basic confirmation UI
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(symbol)
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            if let companyName = overview.profile.companyName {
                                Text(companyName)
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Divider()

                        // API Response Confirmation
                        VStack(alignment: .leading, spacing: 12) {
                            Text("API Response Success")
                                .font(.headline)

                            Group {
                                InfoRow(label: "Symbol", value: overview.symbol)
                                InfoRow(label: "Last Updated", value: overview.lastUpdated ?? "N/A")
                                InfoRow(label: "Overall Score", value: "\(overview.score.overall)/\(overview.score.maxScore)")
                            }
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

                        // Score Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Score Breakdown")
                                .font(.headline)

                            Group {
                                InfoRow(label: "Revenue", value: "\(overview.score.breakdown.revenue)")
                                InfoRow(label: "Operating Income", value: "\(overview.score.breakdown.operatingIncome)")
                                InfoRow(label: "Free Cash Flow", value: "\(overview.score.breakdown.freeCashFlow)")
                                InfoRow(label: "Profit Margin", value: "\(overview.score.breakdown.profitMargin)")
                            }
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

                        // Momentum
                        if let momentum = overview.momentum {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Momentum")
                                    .font(.headline)

                                Group {
                                    InfoRow(label: "Score", value: "\(momentum.score)")
                                    InfoRow(label: "Signal", value: momentum.signal)
                                    InfoRow(label: "Strength", value: momentum.strength)
                                    InfoRow(label: "Date", value: momentum.date)
                                }
                            }
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }

                        // Recent Earnings
                        if !overview.earnings.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Earnings")
                                    .font(.headline)

                                ForEach(overview.earnings.prefix(3)) { earning in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(earning.date)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        HStack {
                                            Text("EPS:")
                                            if let actual = earning.epsActual {
                                                Text("\(actual, specifier: "%.2f")")
                                            } else if let estimated = earning.epsEstimated {
                                                Text("Est: \(estimated, specifier: "%.2f")")
                                                    .foregroundStyle(.secondary)
                                            } else {
                                                Text("N/A")
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                        .font(.caption)
                                    }
                                    .padding(.vertical, 4)

                                    if earning.id != overview.earnings.prefix(3).last?.id {
                                        Divider()
                                    }
                                }
                            }
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding()
                }
            }
        }
        .task(id: symbol) {
            await service.fetchOverview(for: symbol)
        }
    }
}

// Helper view for displaying key-value pairs
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

#Preview {
    NavigationStack {
        StockOverviewView(service: StockService(), symbol: "AAPL")
    }
}
