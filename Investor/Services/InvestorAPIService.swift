//
//  InvestorAPIService.swift
//  Investor
//
//  API client for investor-api-service backend
//  Created by Claude Code on 01/17/26.
//

import Foundation

/// API client for communicating with investor-api-service
@MainActor
final class InvestorAPIService {
    static let shared = InvestorAPIService()

    private let baseURL: String
    private let keychainManager = KeychainManager.shared

    private init() {
        // TODO: Load from configuration
        #if DEBUG
        self.baseURL = "http://localhost:3000/api"
        #else
        self.baseURL = "https://api.investor.app/api"
        #endif
    }

    // MARK: - Authentication Headers

    private func getAuthHeaders() throws -> [String: String] {
        guard let token = keychainManager.getAuthToken() else {
            throw InvestorAPIError.notAuthenticated
        }

        return [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
    }

    // MARK: - User & Subscription

    /// Fetch current user's subscription status from server
    func fetchUserSubscription() async throws -> UserSubscriptionResponse {
        // TODO: Implement API call to /user/subscription
        throw InvestorAPIError.notImplemented
    }

    /// Check if user can access a specific feature
    func canAccessFeature(_ feature: String) async throws -> FeatureAccessResponse {
        // TODO: Implement API call to /user/features/:feature
        throw InvestorAPIError.notImplemented
    }

    /// Check if user can view a specific stock
    func canViewStock(symbol: String) async throws -> StockAccessResponse {
        // TODO: Implement API call to /user/stocks/access/:symbol
        throw InvestorAPIError.notImplemented
    }

    /// Record a stock view (for usage tracking)
    func recordStockView(symbol: String) async throws {
        // TODO: Implement API call to POST /user/stocks/view
        throw InvestorAPIError.notImplemented
    }
}

// MARK: - Response Models

struct UserSubscriptionResponse: Codable {
    let privilegeLevel: PrivilegeLevel
    let subscriptionExpiryDate: Date?
    let stocksViewedThisMonth: Int
    let stockLimitPerMonth: Int?
}

struct FeatureAccessResponse: Codable {
    let canAccess: Bool
    let reason: String?
}

struct StockAccessResponse: Codable {
    let canAccess: Bool
    let reason: String?
}

// MARK: - API Errors

enum InvestorAPIError: LocalizedError {
    case notAuthenticated
    case notImplemented
    case invalidResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "User is not authenticated"
        case .notImplemented:
            return "API method not yet implemented"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let message):
            return "Server error: \(message)"
        }
    }
}
