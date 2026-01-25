//
//  StockListCache.swift
//  Investor
//
//  Cache manager for stock list with 24-hour expiration
//  Uses file-based caching to handle large datasets (>4MB)
//

import Foundation

/// Actor-based cache manager for stock list data with 24-hour expiration
/// Uses file-based caching instead of UserDefaults to support large datasets (>4MB)
actor StockListCache {
    static let shared = StockListCache()

    private let cacheFileName = "stockListCache.json"
    private let timestampKey = "com.investor.stockListTimestamp"
    private let cacheExpirationInterval: TimeInterval = 24 * 60 * 60 // 24 hours

    private init() {}

    // MARK: - Private Methods

    private func getCacheFileURL() -> URL? {
        let fileManager = FileManager.default
        #if os(macOS)
        guard let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        #else
        guard let cacheDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        #endif

        return cacheDir.appendingPathComponent(cacheFileName)
    }

    // MARK: - Public Methods

    /// Get cached stock list if still valid (< 24 hours old)
    func getCachedList() -> [StockListItem]? {
        guard isCacheValid() else {
            return nil
        }

        guard let cacheURL = getCacheFileURL() else {
            return nil
        }

        do {
            let data = try Data(contentsOf: cacheURL)
            let decoder = JSONDecoder()
            let stocks = try decoder.decode([StockListItem].self, from: data)
            print("📦 [Cache] Loaded \(stocks.count) stocks from file cache")
            return stocks
        } catch {
            print("❌ [Cache] Failed to load cached data: \(error)")
            return nil
        }
    }

    /// Save stock list to cache with current timestamp
    func saveList(_ stocks: [StockListItem]) {
        do {
            guard let cacheURL = getCacheFileURL() else {
                print("❌ [Cache] Could not determine cache directory")
                return
            }

            let encoder = JSONEncoder()
            let data = try encoder.encode(stocks)

            try data.write(to: cacheURL, options: .atomic)
            UserDefaults.standard.set(Date(), forKey: timestampKey)

            print("💾 [Cache] Saved \(stocks.count) stocks to file cache (\(String(format: "%.1f", Double(data.count) / 1024 / 1024))MB)")
        } catch {
            print("❌ [Cache] Failed to save stocks: \(error)")
        }
    }

    /// Check if cache is still valid (< 24 hours old)
    func isCacheValid() -> Bool {
        guard let cacheURL = getCacheFileURL() else {
            return false
        }

        guard FileManager.default.fileExists(atPath: cacheURL.path) else {
            return false
        }

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
        if let cacheURL = getCacheFileURL() {
            try? FileManager.default.removeItem(at: cacheURL)
        }
        UserDefaults.standard.removeObject(forKey: timestampKey)
        // Also clear old UserDefaults cache key for migration
        UserDefaults.standard.removeObject(forKey: "com.investor.stockListData")
        print("🗑️ [Cache] Cleared stock list cache")
    }

    /// Migrate from old UserDefaults cache to file-based cache
    func migrateOldCache() {
        // Clear the old UserDefaults cache key if it exists
        if UserDefaults.standard.object(forKey: "com.investor.stockListData") != nil {
            UserDefaults.standard.removeObject(forKey: "com.investor.stockListData")
            print("🔄 [Cache] Migrated away from old UserDefaults storage")
        }
    }
}
