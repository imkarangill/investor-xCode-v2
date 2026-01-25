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
                    StockHeader(overview: overview)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding()
        }
        .task(id: symbol) {
            await service.fetchOverview(for: symbol)
        }
    }
}


#Preview {
    NavigationStack {
        StockOverviewView(service: StockService(), symbol: "AAPL")
    }
}


