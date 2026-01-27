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
                        //.padding(.bottom)
                    StockTabs().padding(.bottom)
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
}


#Preview {
    NavigationStack {
        StockOverviewView(service: StockService(), symbol: "AAPL")
    }
}


