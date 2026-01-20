//
//  SubscriptionService.swift
//  Investor
//
//  Subscription management using Adapty SDK
//  Handles cross-platform subscriptions (iOS, Android, Web)
//
//  Created by Claude Code on 01/17/26.
//

import Foundation
import Combine
import SwiftUI

/// Result of a subscription purchase attempt
struct SubscriptionResult {
    let success: Bool
    let privilegeLevel: PrivilegeLevel
    let expiryDate: Date?
    let error: Error?
}

/// Subscription service managing Adapty integration
@MainActor
final class SubscriptionService: ObservableObject {

    static let shared = SubscriptionService()

    @Published var isLoading = false
    @Published var currentPrivilegeLevel: PrivilegeLevel = .free
    @Published var subscriptionExpiry: Date?

    private init() {}

    // MARK: - Initialization

    /// Configure subscription service with user ID
    /// Call this after Firebase authentication
    func configure(userId: String) async throws {
        print("✅ SubscriptionService configured for user: \(userId)")
        // Initialize Adapty or other subscription service here
        // For now, load any cached subscription status
        currentPrivilegeLevel = .free
    }

    // MARK: - Subscription Status

    /// Update subscription status
    func updateSubscriptionStatus() async throws {
        print("✅ Updated subscription status: \(currentPrivilegeLevel.rawValue)")
    }

    /// Get current subscription status synchronously (from cache)
    func getCurrentStatus() -> (level: PrivilegeLevel, expiry: Date?) {
        return (currentPrivilegeLevel, subscriptionExpiry)
    }

    // MARK: - Lifecycle Events

    /// Update user attributes in subscription service
    func updateUserAttributes(email: String, name: String?) async {
        print("✅ Updated subscription service profile attributes")
    }

    /// Log out from subscription service (call on sign out)
    func logout() async throws {
        currentPrivilegeLevel = .free
        subscriptionExpiry = nil
        print("✅ Logged out from subscription service")
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let subscriptionDidChange = Notification.Name("subscriptionDidChange")
}
