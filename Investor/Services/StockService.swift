//
//  StockService.swift
//  Investor
//
//  Business logic for stock data
//

import Foundation
import Combine
import SwiftUI

@MainActor
class StockService: ObservableObject {
    // MARK: - Published State

    @Published var stockOverview: StockOverview?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var lastUpdated: Date?

    // MARK: - Private

    private let apiClient = APIClient.shared
    private var loadedSymbol: String?

    // MARK: - Public Methods

    /// Fetch stock overview for a symbol
    func fetchOverview(for symbol: String) async {
        // Avoid redundant fetches
        guard symbol != loadedSymbol || stockOverview == nil else { return }

        isLoading = true
        error = nil

        do {
            let overview = try await apiClient.fetchStockOverview(symbol: symbol)
            stockOverview = overview
            loadedSymbol = symbol
            lastUpdated = Date()
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Force refresh the current stock
    func refresh() async {
        guard let symbol = loadedSymbol else { return }
        loadedSymbol = nil // Force refetch
        await fetchOverview(for: symbol)
    }

    /// Clear current data
    func clear() {
        stockOverview = nil
        loadedSymbol = nil
        error = nil
    }
}

// MARK: - Formatting Helpers

extension StockService {
    /// Format a growth value as percentage string
    static func formatGrowth(_ value: Double?) -> String {
        guard let value = value else { return "—" }
        let percentage = value * 100
        let sign = percentage >= 0 ? "" : ""
        return String(format: "%@%.0f%%", sign, percentage)
    }

    /// Format a ratio value
    static func formatRatio(_ value: Double?) -> String {
        guard let value = value else { return "—" }
        return String(format: "%.2f", value)
    }

    /// Format market cap
    static func formatMarketCap(_ value: Int64?) -> String {
        guard let value = value else { return "—" }

        let billion = 1_000_000_000.0
        let million = 1_000_000.0

        if Double(value) >= billion {
            return String(format: "$%.1fB", Double(value) / billion)
        } else if Double(value) >= million {
            return String(format: "$%.1fM", Double(value) / million)
        } else {
            return "$\(value)"
        }
    }

    /// Format price
    static func formatPrice(_ value: Double?, currency: String? = "USD") -> String {
        guard let value = value else { return "—" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency ?? "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "—"
    }

    /// Color for a growth value
    static func colorForGrowth(_ value: Double?) -> Color {
        guard let value = value else { return AppTheme.Colors.neutral }
        return value >= 0 ? AppTheme.Colors.positive : AppTheme.Colors.negative
    }
}
