//
//  AuthenticationService.swift
//  Investor
//
//  Firebase-based authentication service for Google and Apple Sign-In
//  Created by Claude Code on 01/17/26.
//
//  NOTE: Requires Firebase to be added via SPM (firebase-ios-sdk)
//  Add to Xcode: File → Add Packages → https://github.com/firebase/firebase-ios-sdk.git
//  Select version 11.0.0 or later
//

import Foundation
import AuthenticationServices
import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// Conditional imports for Firebase (only available after SPM setup)
#if canImport(FirebaseAuth)
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import CommonCrypto
#endif

/// Result of an authentication attempt
struct AuthResult {
    let user: User
    let isNewUser: Bool
}

#if canImport(FirebaseAuth)

/// Authentication service managing Firebase auth with Google and Apple Sign-In
@MainActor
final class AuthenticationService: NSObject, ObservableObject {

    static let shared = AuthenticationService()

    @Published var isLoading = false
    @Published var errorMessage: String?

    private let keychainManager = KeychainManager.shared
    private var authStateListener: NSObjectProtocol?
    var currentNonce: String?

    private override init() {
        super.init()
        setupAuthStateListener()
    }

    // MARK: - Auth State Listener

    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    try? await self?.handleAuthStateChange(firebaseUser: user)
                } else {
                    self?.handleSignOut()
                }
            }
        }
    }

    // MARK: - Google Sign-In

    /// Sign in with Google
    func signInWithGoogle() async throws -> AuthResult {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        #if os(iOS)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.noPresentingViewController
        }
        #elseif os(macOS)
        guard let window = NSApplication.shared.windows.first else {
            throw AuthError.noPresentingViewController
        }
        #else
        throw AuthError.noPresentingViewController
        #endif

        do {
            #if os(iOS)
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            #elseif os(macOS)
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: window)
            #else
            throw AuthError.noPresentingViewController
            #endif

            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.missingIDToken
            }

            let accessToken = result.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            let authResult = try await Auth.auth().signIn(with: credential)

            if let firebaseToken = try? await authResult.user.getIDToken() {
                try? keychainManager.saveAuthToken(firebaseToken)
            }

            try? keychainManager.saveUserID(authResult.user.uid)
            if let email = authResult.user.email {
                try? keychainManager.saveUserEmail(email)
            }

            let user = try await createUserFromFirebase(authResult.user)

            return AuthResult(
                user: user,
                isNewUser: authResult.additionalUserInfo?.isNewUser ?? false
            )

        } catch {
            errorMessage = "Google Sign-In failed: \(error.localizedDescription)"
            throw error
        }
    }

    // MARK: - Apple Sign-In

    /// Sign in with Apple
    func signInWithApple() async throws -> AuthResult {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let nonce = randomNonceString()
        currentNonce = nonce
        let hashedNonce = sha256(nonce)

        return try await Task.detached(priority: .high) { [weak self] in
            try await withCheckedThrowingContinuation { continuation in
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let request = appleIDProvider.createRequest()
                request.requestedScopes = [.fullName, .email]
                request.nonce = hashedNonce

                let authorizationController = ASAuthorizationController(authorizationRequests: [request])

                let delegate = AppleSignInDelegate { [weak self] result in
                    switch result {
                    case .success(let authResult):
                        continuation.resume(returning: authResult)
                    case .failure(let error):
                        Task { @MainActor [weak self] in
                            self?.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
                        }
                        continuation.resume(throwing: error)
                    }
                }

                authorizationController.delegate = delegate
                authorizationController.presentationContextProvider = delegate

                DispatchQueue.main.async {
                    authorizationController.performRequests()
                }

                objc_setAssociatedObject(
                    authorizationController,
                    "delegate",
                    delegate,
                    .OBJC_ASSOCIATION_RETAIN
                )
            }
        }
    }

    /// Handle Apple Sign-In credential
    func handleAppleSignInCredential(
        _ authorization: ASAuthorization,
        nonce: String
    ) async throws -> AuthResult {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.invalidAppleCredential
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )

        let authResult = try await Auth.auth().signIn(with: credential)
        let email = authResult.user.email ?? appleIDCredential.email

        if let firebaseToken = try? await authResult.user.getIDToken() {
            try? keychainManager.saveAuthToken(firebaseToken)
        }

        try? keychainManager.saveUserID(authResult.user.uid)
        if let email = email {
            try? keychainManager.saveUserEmail(email)
            print("📧 [Auth] Captured email: \(email)")
        }

        var user = try await createUserFromFirebase(authResult.user)

        if let fullName = appleIDCredential.fullName {
            let displayName = [fullName.givenName, fullName.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            if !displayName.isEmpty {
                user.name = displayName
            }
        }

        return AuthResult(
            user: user,
            isNewUser: authResult.additionalUserInfo?.isNewUser ?? false
        )
    }

    // MARK: - Sign Out

    /// Sign out the current user
    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        keychainManager.clearAll()

        Task {
            try? await SubscriptionService.shared.logout()
        }
    }

    private func handleSignOut() {
        Task {
            await MainActor.run {
                PrivilegeManager.shared.currentUser = nil
                PrivilegeManager.shared.isAuthenticated = false
            }
        }
    }

    // MARK: - Helper Methods

    private func handleAuthStateChange(firebaseUser: FirebaseAuth.User) async throws {
        let user = try await createUserFromFirebase(firebaseUser)
        await MainActor.run {
            PrivilegeManager.shared.signIn(user: user)
        }
    }

    private func createUserFromFirebase(_ firebaseUser: FirebaseAuth.User) async throws -> User {
        var authProvider: User.AuthProvider = .development
        if let providerID = firebaseUser.providerData.first?.providerID {
            switch providerID {
            case "google.com":
                authProvider = .google
            case "apple.com":
                authProvider = .apple
            default:
                break
            }
        }

        var privilegeLevel: PrivilegeLevel = .free
        var subscriptionExpiry: Date?

        do {
            try await SubscriptionService.shared.configure(userId: firebaseUser.uid)
            await SubscriptionService.shared.updateUserAttributes(
                email: firebaseUser.email ?? "",
                name: firebaseUser.displayName
            )

            let status = SubscriptionService.shared.getCurrentStatus()
            privilegeLevel = status.level
            subscriptionExpiry = status.expiry

        } catch {
            print("⚠️ Failed to sync subscription: \(error.localizedDescription)")
        }

        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            name: firebaseUser.displayName ?? "User",
            privilegeLevel: privilegeLevel,
            subscriptionExpiryDate: subscriptionExpiry,
            authProvider: authProvider
        )
    }

    // MARK: - Nonce Generation

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }

        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

        let nonce = randomBytes.map { byte in
            charset[Int(byte) % charset.count]
        }

        return String(nonce)
    }

    private func sha256(_ input: String) -> String {
        guard let inputData = input.data(using: .utf8) else { return "" }

        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        inputData.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(inputData.count), &hash)
        }

        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Apple Sign-In Delegate

private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private let completion: (Result<AuthResult, Error>) -> Void

    init(completion: @escaping (Result<AuthResult, Error>) -> Void) {
        self.completion = completion
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task.detached { [weak self] in
            do {
                guard let nonce = await AuthenticationService.shared.currentNonce else {
                    throw AuthError.missingNonce
                }

                let result = try await AuthenticationService.shared.handleAppleSignInCredential(
                    authorization,
                    nonce: nonce
                )
                self?.completion(.success(result))
            } catch {
                self?.completion(.failure(error))
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if os(iOS)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
        #elseif os(macOS)
        return NSApplication.shared.windows.first ?? ASPresentationAnchor()
        #else
        return ASPresentationAnchor()
        #endif
    }
}

#else

// MARK: - Stub Implementation (Firebase not available)

import Combine

@MainActor
final class AuthenticationService: NSObject, ObservableObject {
    static let shared = AuthenticationService()
    @Published var isLoading = false
    @Published var errorMessage: String?

    private override init() { super.init() }

    func signInWithGoogle() async throws -> AuthResult {
        throw AuthError.notAuthenticated
    }

    func signInWithApple() async throws -> AuthResult {
        throw AuthError.notAuthenticated
    }

    func signOut() throws {
        print("⚠️ Firebase not configured - sign out unavailable")
    }
}

#endif

// MARK: - Errors

enum AuthError: LocalizedError {
    case missingClientID
    case noPresentingViewController
    case missingIDToken
    case invalidAppleCredential
    case missingNonce
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Missing Google Client ID from Firebase configuration"
        case .noPresentingViewController:
            return "Cannot find presenting view controller"
        case .missingIDToken:
            return "Missing ID token from sign-in"
        case .invalidAppleCredential:
            return "Invalid Apple Sign-In credential"
        case .missingNonce:
            return "Missing nonce for Apple Sign-In"
        case .notAuthenticated:
            return "User is not authenticated"
        }
    }
}
