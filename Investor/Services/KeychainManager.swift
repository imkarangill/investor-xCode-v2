//
//  KeychainManager.swift
//  Investor
//
//  Created by Claude Code on 01/17/26.
//

import Foundation
import Security

/// Manages secure storage of authentication tokens and user data in Keychain
@MainActor
final class KeychainManager {
    static let shared = KeychainManager()

    private let authTokenKey = "com.investor.authToken"
    private let userIDKey = "com.investor.userID"
    private let userEmailKey = "com.investor.userEmail"
    private let adminKeyKey = "com.investor.adminKey"
    private let serviceName = "com.investor.auth"

    private init() {}

    // MARK: - Auth Token

    func saveAuthToken(_ token: String) throws {
        let data = token.data(using: .utf8) ?? Data()
        try saveKeychain(key: authTokenKey, data: data)
    }

    func getAuthToken() -> String? {
        guard let data = try? loadKeychain(key: authTokenKey) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - User ID

    func saveUserID(_ userID: String) throws {
        let data = userID.data(using: .utf8) ?? Data()
        try saveKeychain(key: userIDKey, data: data)
    }

    func getUserID() -> String? {
        guard let data = try? loadKeychain(key: userIDKey) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - User Email

    func saveUserEmail(_ email: String) throws {
        let data = email.data(using: .utf8) ?? Data()
        try saveKeychain(key: userEmailKey, data: data)
    }

    func getUserEmail() -> String? {
        guard let data = try? loadKeychain(key: userEmailKey) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Admin Key

    func saveAdminKey(_ key: String) throws {
        let data = key.data(using: .utf8) ?? Data()
        try saveKeychain(key: adminKeyKey, data: data)
    }

    func getAdminKey() -> String? {
        guard let data = try? loadKeychain(key: adminKeyKey) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Clear All

    func clearAll() {
        try? deleteKeychain(key: authTokenKey)
        try? deleteKeychain(key: userIDKey)
        try? deleteKeychain(key: userEmailKey)
        try? deleteKeychain(key: adminKeyKey)
    }

    // MARK: - Private Helpers

    private func saveKeychain(key: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveError(status)
        }
    }

    private func loadKeychain(key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            throw KeychainError.loadError(status)
        }

        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }

        return data
    }

    private func deleteKeychain(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteError(status)
        }
    }
}

// MARK: - Keychain Errors

enum KeychainError: LocalizedError {
    case saveError(OSStatus)
    case loadError(OSStatus)
    case deleteError(OSStatus)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .saveError(let status):
            return "Failed to save to Keychain (status: \(status))"
        case .loadError(let status):
            return "Failed to load from Keychain (status: \(status))"
        case .deleteError(let status):
            return "Failed to delete from Keychain (status: \(status))"
        case .invalidData:
            return "Invalid data from Keychain"
        }
    }
}
