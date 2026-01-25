//
//  PrivilegeManager.swift
//  Investor
//
//  Manages user authentication state
//  Created by Claude Code on 01/17/26.
//

import Foundation
import Combine

/// Manages user authentication state
@MainActor
final class PrivilegeManager: ObservableObject {
    static let shared = PrivilegeManager()

    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var showLoginSheet: Bool = false
    @Published var hasCompletedSubscriptionFlow: Bool = false

    // MARK: - Private Properties
    private let userDefaultsKey = "com.investor.currentUser"
    private let hasCompletedSubscriptionFlowKey = "com.investor.hasCompletedSubscriptionFlow"

    // Development bypass flag - set to true when running from Xcode
    #if DEBUG
    var developmentBypass: Bool = false
    #endif

    private init() {
        loadUser()
        loadSubscriptionFlowState()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSubscriptionChange),
            name: .subscriptionDidChange,
            object: nil
        )
    }

    @objc private func handleSubscriptionChange(_ notification: Notification) {
        Task { @MainActor in
            try? await SubscriptionService.shared.updateSubscriptionStatus()
            let status = SubscriptionService.shared.getCurrentStatus()

            if let existingUser = currentUser {
                let updatedUser = User(
                    id: existingUser.id,
                    email: existingUser.email,
                    name: existingUser.name,
                    privilegeLevel: status.level,
                    subscriptionExpiryDate: status.expiry,
                    authProvider: existingUser.authProvider
                )
                currentUser = updatedUser
                saveUser()
                print("✅ Updated user subscription: \(status.level.rawValue)")
            }
        }
    }

    // MARK: - Authentication

    /// Sign in with development bypass (Xcode only)
    func signInWithDevelopmentBypass() {
        let devUser = User(
            id: "dev-user-001",
            email: "dev@investor.app",
            name: "Developer",
            privilegeLevel: .admin,
            subscriptionExpiryDate: nil,
            authProvider: .development
        )
        currentUser = devUser
        isAuthenticated = true
        #if DEBUG
        developmentBypass = true
        #endif
        saveUser()
        print("✅ Development bypass enabled - Admin access granted")
    }

    /// Sign in with Google using Firebase Authentication
    func signInWithGoogle() async throws {
        let result = try await AuthenticationService.shared.signInWithGoogle()
        signIn(user: result.user)
    }

    /// Sign in with Apple using Firebase Authentication
    func signInWithApple() async throws {
        let result = try await AuthenticationService.shared.signInWithApple()
        signIn(user: result.user)
    }

    /// Internal method to handle successful sign-in
    func signIn(user: User) {
        currentUser = user
        isAuthenticated = true
        saveUser()
        // Check if subscription flow is needed for new free users
        evaluateSubscriptionFlowState()
        print("✅ User signed in: \(user.email), Level: \(user.privilegeLevel.rawValue), Provider: \(user.authProvider.rawValue)")
    }

    /// Sign out current user
    func signOut() {
        let wasOAuthUser = currentUser?.authProvider != .development

        currentUser = nil
        isAuthenticated = false
        hasCompletedSubscriptionFlow = false
        #if DEBUG
        developmentBypass = false
        #endif
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: hasCompletedSubscriptionFlowKey)

        if wasOAuthUser {
            try? AuthenticationService.shared.signOut()
        }

        print("✅ User signed out")
    }

    // MARK: - Persistence

    private func saveUser() {
        guard let user = currentUser,
              let encoded = try? JSONEncoder().encode(user) else { return }
        UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
    }

    private func loadUser() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            isAuthenticated = false
            return
        }
        currentUser = user
        isAuthenticated = true

        #if DEBUG
        if user.authProvider == .development {
            developmentBypass = true
        }
        #endif
    }

    // MARK: - API Integration

    /// Check if user can access a feature
    /// Calls investor-api-service to verify access based on subscription tier
    func canAccessFeature(_ feature: String) async throws -> Bool {
        let response = try await InvestorAPIService.shared.canAccessFeature(feature)
        return response.canAccess
    }

    /// Check if user can view a stock
    /// Calls investor-api-service to verify access and usage limits
    func canViewStock(symbol: String) async throws -> (allowed: Bool, reason: String?) {
        let response = try await InvestorAPIService.shared.canViewStock(symbol: symbol)
        return (response.canAccess, response.reason)
    }

    /// Record a stock view
    /// Sends tracking event to investor-api-service for usage monitoring
    func recordStockView(symbol: String) async throws {
        try await InvestorAPIService.shared.recordStockView(symbol: symbol)
    }

    // MARK: - Subscription Flow

    /// Computed property to determine if subscription flow is needed
    var needsSubscriptionFlow: Bool {
        guard isAuthenticated, let user = currentUser else { return false }

        // Skip flow if:
        // 1. User has completed flow before
        // 2. User has paid subscription (Pro, Max, Ultimate, Admin)
        let hasCompleted = hasCompletedSubscriptionFlow
        let isPaidTier = user.privilegeLevel != .free

        return !hasCompleted && !isPaidTier
    }

    /// Mark subscription flow as complete
    func completeSubscriptionFlow() {
        UserDefaults.standard.set(true, forKey: hasCompletedSubscriptionFlowKey)
        hasCompletedSubscriptionFlow = true
    }

    /// Private helper to evaluate subscription flow state based on current user
    private func evaluateSubscriptionFlowState() {
        guard let user = currentUser else { return }

        // If user has paid tier, mark flow as complete
        if user.privilegeLevel != .free {
            UserDefaults.standard.set(true, forKey: hasCompletedSubscriptionFlowKey)
            hasCompletedSubscriptionFlow = true
        }
    }

    /// Load subscription flow state from UserDefaults
    private func loadSubscriptionFlowState() {
        hasCompletedSubscriptionFlow = UserDefaults.standard.bool(forKey: hasCompletedSubscriptionFlowKey)
    }

    // MARK: - Helpers

    /// Show login sheet
    func requireLogin() {
        showLoginSheet = true
    }
}
