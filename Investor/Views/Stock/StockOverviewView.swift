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

    // MARK: - Computed Properties

    var subscriptionWarning: String? {
        guard service.viewsRemaining > 0 || service.viewsRemaining == 0 else { return nil }

        switch service.subscriptionTier {
        case "free":
            if service.viewsRemaining == 0 {
                return "You've reached your limit of \(service.viewsLimit) stocks. Upgrade to unlock more."
            } else if service.viewsRemaining == 1 {
                return "Only \(service.viewsRemaining) stock remaining. Upgrade to unlock more."
            }
        case "pro":
            if service.viewsRemaining <= 10 && service.viewsRemaining > 0 {
                return "\(service.viewsRemaining) stocks remaining this month"
            }
        default:
            break
        }
        return nil
    }

    var body: some View {
        ZStack(alignment: .top) {
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
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer()
                            .frame(height: 140)

                        // Show subscription limit warning if applicable
                        if let warningMessage = subscriptionWarning {
                            subscriptionWarningBanner(message: warningMessage)
                        }

                        GrowthTileContent(overview: overview)
                        RatiosTileContent(overview: overview)
                        ReturnsTileContent(overview: overview)
                        ValuationTileContent(overview: overview)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.horizontal)
                    .padding(.bottom)
                }

                VStack(spacing: 0) {
                    StockHeader(overview: overview)
                }
//                .padding(.bottom,  20)
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .task(id: symbol) {
            await service.fetchOverview(for: symbol)
        }
        .padding()
    }

    // MARK: - Helper Views

    @ViewBuilder
    func subscriptionWarningBanner(message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text("Subscription Limit")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }
}


#Preview {
    NavigationStack {
        StockOverviewView(service: StockService(), symbol: "AAPL")
    }
}


