//
//  StockListCache.swift
//  Investor
//
//  Cache manager for stock list with 24-hour expiration
//

import Foundation

/// Actor-based cache manager for stock list data with 24-hour expiration
actor StockListCache {
    static let shared = StockListCache()

    private let cacheKey = "com.investor.stockListData"
    private let timestampKey = "com.investor.stockListTimestamp"
    private let cacheExpirationInterval: TimeInterval = 24 * 60 * 60 // 24 hours

    private init() {}

    // MARK: - Public Methods

    /// Get cached stock list if still valid (< 24 hours old)
    func getCachedList() -> [StockListItem]? {
        guard isCacheValid() else {
            return nil
        }

        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let stocks = try decoder.decode([StockListItem].self, from: data)
            print("📦 [Cache] Loaded \(stocks.count) stocks from cache")
            return stocks
        } catch {
            print("❌ [Cache] Failed to decode cached data: \(error)")
            return nil
        }
    }

    /// Save stock list to cache with current timestamp
    func saveList(_ stocks: [StockListItem]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(stocks)

            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: timestampKey)

            print("💾 [Cache] Saved \(stocks.count) stocks to cache")
        } catch {
            print("❌ [Cache] Failed to save stocks: \(error)")
        }
    }

    /// Check if cache is still valid (< 24 hours old)
    func isCacheValid() -> Bool {
        guard let timestamp = UserDefaults.standard.object(forKey: timestampKey) as? Date else {
            return false
        }

        let age = Date().timeIntervalSince(timestamp)
        let isValid = age < cacheExpirationInterval

        if isValid {
            let hoursRemaining = (cacheExpirationInterval - age) / 3600
            print("✅ [Cache] Valid - expires in \(String(format: "%.1f", hoursRemaining)) hours")
        } else {
            print("⏰ [Cache] Expired - last updated \(String(format: "%.1f", age / 3600)) hours ago")
        }

        return isValid
    }

    /// Clear cached stock list
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: timestampKey)
        print("🗑️ [Cache] Cleared stock list cache")
    }
}
