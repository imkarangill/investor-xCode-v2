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

    // MARK: - Subscription Limits (from API response metadata)

    @Published var viewsUsed: Int = 0
    @Published var viewsLimit: Int = 0
    @Published var viewsRemaining: Int = 0
    @Published var subscriptionTier: String = "free"

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

            // Safely extract and store subscription limit information from metadata
            // Using separate unwrapping to avoid potential memory access issues
            if let metadata = overview._metadata {
                if let viewStats = metadata.viewStats {
                    viewsUsed = viewStats.viewsUsed
                    viewsLimit = viewStats.viewsLimit
                    viewsRemaining = viewStats.viewsRemaining
                    subscriptionTier = viewStats.tier
                }
            }

            stockOverview = overview
            loadedSymbol = symbol
            lastUpdated = Date()
        } catch let error as APIClientError {
            self.error = handleStockError(error)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    /// Handle API client errors and provide user-friendly messages
    private func handleStockError(_ error: APIClientError) -> Error {
        switch error {
        case .forbidden(let message):
            // Subscription limit exceeded
            return NSError(
                domain: "StockService",
                code: 403,
                userInfo: [
                    NSLocalizedDescriptionKey: message.isEmpty
                        ? "You've reached your limit of \(viewsLimit) stocks for \(subscriptionTier) tier"
                        : message
                ]
            )

        case .badRequest(let message):
            // Subscription lookup failed
            return NSError(
                domain: "StockService",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Subscription error: \(message)"]
            )

        default:
            return error
        }
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
        viewsUsed = 0
        viewsLimit = 0
        viewsRemaining = 0
        subscriptionTier = "free"
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
