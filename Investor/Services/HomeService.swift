//
//  HomeService.swift
//  Investor
//
//  Service for managing home screen data with caching
//

import Foundation
import Combine
import SwiftUI

@MainActor
class HomeService: ObservableObject {
    // MARK: - Published State

    @Published var homeData: HomeResponse?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var lastUpdated: Date?

    // MARK: - Private

    private let apiClient = APIClient.shared
    private let cacheKey = "com.investor.homeData"
    private let timestampKey = "com.investor.homeDataTimestamp"
    private let cacheExpirationInterval: TimeInterval = 5 * 60 // 5 minutes

    // MARK: - Init

    init() {
        loadCachedData()
    }

    // MARK: - Public Methods

    /// Fetch home screen data from API
    func fetchHome() async {
        isLoading = true
        error = nil

        do {
            print("🏠 [HomeService] Starting fetch from /api/v1/users/me/home")
            let response = try await apiClient.fetchHome()
            print("✅ [HomeService] Successfully fetched home data")
            print("📊 [HomeService] Portfolio items: \(response.portfolio.count)")
            print("📊 [HomeService] Watchlists: \(response.watchlists.count)")
            print("📊 [HomeService] Recently viewed: \(response.recentlyViewed.count)")

            homeData = response
            lastUpdated = Date()

            // Cache the response
            cacheHomeData(response)
            print("💾 [HomeService] Home data cached successfully")
        } catch let error as APIClientError {
            print("❌ [HomeService] APIClientError: \(error.errorDescription ?? "Unknown error")")
            self.error = error
            // Try to use cached data as fallback
            if homeData == nil {
                print("ℹ️ [HomeService] Loading cached data as fallback")
                loadCachedData()
            }
        } catch {
            print("❌ [HomeService] Unexpected error: \(error.localizedDescription)")
            print("❌ [HomeService] Error type: \(type(of: error))")
            self.error = error
            // Try to use cached data as fallback
            if homeData == nil {
                print("ℹ️ [HomeService] Loading cached data as fallback")
                loadCachedData()
            }
        }

        isLoading = false
    }

    // MARK: - Private Methods

    /// Load cached home data if available
    private func loadCachedData() {
        guard isCacheValid() else {
            print("⏰ [HomeService] Cache not valid or expired")
            return
        }

        print("📦 [HomeService] Loading from cache...")
        do {
            if let data = UserDefaults.standard.data(forKey: cacheKey) {
                let decoder = JSONDecoder()
                let cachedResponse = try decoder.decode(HomeResponse.self, from: data)
                homeData = cachedResponse
                lastUpdated = UserDefaults.standard.object(forKey: timestampKey) as? Date
                print("✅ [HomeService] Loaded \(cachedResponse.portfolio.count) portfolio items from cache")
            } else {
                print("❌ [HomeService] No cached data found")
            }
        } catch {
            print("❌ [HomeService] Failed to load cached home data: \(error)")
        }
    }

    /// Cache home response data
    private func cacheHomeData(_ response: HomeResponse) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(response)
            UserDefaults.standard.set(data, forKey: cacheKey)
            UserDefaults.standard.set(Date(), forKey: timestampKey)
        } catch {
            print("Failed to cache home data: \(error)")
        }
    }

    /// Check if cache is still valid
    private func isCacheValid() -> Bool {
        guard let timestamp = UserDefaults.standard.object(forKey: timestampKey) as? Date else {
            return false
        }

        let age = Date().timeIntervalSince(timestamp)
        return age < cacheExpirationInterval
    }

    /// Clear cached data
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey)
        UserDefaults.standard.removeObject(forKey: timestampKey)
        homeData = nil
        lastUpdated = nil
        error = nil
    }
}
