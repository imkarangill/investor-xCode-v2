//
//  UserPrivilege.swift
//  Investor
//
//  Created by Claude Code on 01/17/26.
//

import Foundation

/// User privilege levels for app access control
enum PrivilegeLevel: String, Codable, CaseIterable {
    case admin = "Admin"
    case free = "Free"
    case pro = "Pro"
    case max = "Max"
    case ultimate = "Ultimate"
}

/// User model with privilege information
struct User: Codable, Identifiable {
    let id: String
    let email: String
    var name: String?
    let privilegeLevel: PrivilegeLevel
    let subscriptionExpiryDate: Date?
    let authProvider: AuthProvider

    enum AuthProvider: String, Codable {
        case google = "Google"
        case apple = "Apple"
        case development = "Development" // For Xcode bypass
    }

    /// Check if subscription is active
    var isSubscriptionActive: Bool {
        guard let expiryDate = subscriptionExpiryDate else {
            // Free tier or admin - always active
            return privilegeLevel == .free || privilegeLevel == .admin
        }
        return expiryDate > Date()
    }
}
