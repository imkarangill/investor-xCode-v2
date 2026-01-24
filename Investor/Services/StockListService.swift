//
//  StockListService.swift
//  Investor
//
//  Service for managing stock list with caching
//

import Foundation
import Combine

@MainActor
final class StockListService: ObservableObject {
    static let shared = StockListService()

    // MARK: - Published State

    @Published var stocks: [StockListItem] = []
    @Published var isLoading = false
    @Published var lastFetched: Date?
    @Published var error: Error?

    // MARK: - Private

    private let apiClient = APIClient.shared
    private let cache = StockListCache.shared
    private var isInitialized = false

    private init() {}

    // MARK: - Public Methods

    /// Initialize stock list on app startup
    /// Uses cache if valid, otherwise fetches from API
    func initialize() async {
        // Prevent multiple initializations
        guard !isInitialized else {
            print("📋 [StockList] Already initialized")
            return
        }

        print("🚀 [StockList] Initializing...")

        // Try to load from cache first
        if let cachedStocks = await cache.getCachedList() {
            stocks = cachedStocks
            lastFetched = UserDefaults.standard.object(forKey: "com.investor.stockListTimestamp") as? Date
            isInitialized = true
            print("✅ [StockList] Loaded \(stocks.count) stocks from cache")
            return
        }

        // Cache invalid or missing - fetch from API
        print("🌐 [StockList] Cache invalid, fetching from API...")
        await fetchFromAPI(country: "US", silentError: true)
        isInitialized = true
    }

    /// Force refresh stock list from API
    func refresh() async {
        print("🔄 [StockList] Force refresh requested")
        await fetchFromAPI(country: "US", silentError: false)
    }

    /// Fetch stocks for a specific country
    func fetchStocksForCountry(_ countryCode: String) async {
        print("🌍 [StockList] Fetching stocks for country: \(countryCode)")
        await fetchFromAPI(country: countryCode, silentError: false)
    }

    // MARK: - Private Methods

    private func fetchFromAPI(country: String, silentError: Bool) async {
        isLoading = true
        error = nil

        do {
            let fetchedStocks = try await apiClient.fetchStockList(country: country)
            stocks = fetchedStocks
            lastFetched = Date()

            // Save to cache
            await cache.saveList(fetchedStocks)

            print("✅ [StockList] Fetched \(fetchedStocks.count) stocks from API for \(country)")
        } catch {
            self.error = error
            if !silentError {
                print("❌ [StockList] Failed to fetch: \(error.localizedDescription)")
            } else {
                print("⚠️ [StockList] Failed to fetch (silent): \(error.localizedDescription)")
            }

            // Try to use cached data even if expired
            if stocks.isEmpty {
                if let cachedStocks = await cache.getCachedList() {
                    stocks = cachedStocks
                    print("ℹ️ [StockList] Using expired cache as fallback")
                }
            }
        }

        isLoading = false
    }

    /// Clear cache and reset state
    func clearCache() async {
        await cache.clearCache()
        stocks = []
        lastFetched = nil
        isInitialized = false
        print("🗑️ [StockList] Cache cleared and state reset")
    }
}
