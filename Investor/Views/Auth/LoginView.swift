//
//  LoginView.swift
//  Investor
//
//  Created by Claude Code on 01/17/26.
//

import SwiftUI

/// Login and subscription view
struct LoginView: View {
    @ObservedObject var privilegeManager: PrivilegeManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 160) {
            // Header
            VStack(spacing: 20) {
                Image("InvestorLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }

            VStack(spacing: 40) {
#if DEBUG
//                Button(action: signInWithDevelopmentBypass) {
//                    HStack {
//                        Image(systemName: "hammer.fill")
//                        Text("Development Bypass (Admin)")
//                    }
//                    .padding(.vertical, 12)
//                }
                Button(action: signInWithDevelopmentBypass) {
                    Label("Development Bypass (Admin)", systemImage: "hammer.fill")
                        .frame(maxWidth: 300)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .capsule)
                .transition(.scale.combined(with: .opacity))

                Divider()
#endif

                // Apple Sign-In
                Button(action: signInWithApple) {
                    Label("Continue with Apple", systemImage: "apple.logo")
                        .frame(maxWidth: 300)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .capsule)
                .transition(.scale.combined(with: .opacity))

                // Google Sign-In
                Button(action: signInWithGoogle) {
                    Label("Continue with Google", systemImage: "g.circle.fill")
                        .frame(maxWidth: 300)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .capsule)
                .transition(.scale.combined(with: .opacity))
            }
            .padding(.horizontal)
            .background(.background)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .overlay {
            if isLoading {
                ZStack {
                    Color.clear
                        .background(.ultraThinMaterial)

                    VStack(spacing: 16) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Signing in...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .visualEffect { content, _ in
                    content.blur(radius: self.isLoading ? 0 : 10)
                }
                .transition(.opacity)
            }
        }
    }

    // MARK: - Actions

    private func signInWithGoogle() {
        print("[LoginView] Google sign-in initiated")
        withAnimation { isLoading = true }
        Task {
            do {
                try await privilegeManager.signInWithGoogle()
                await MainActor.run {
                    print("[LoginView] Google sign-in successful, transitioning to main app")
                    withAnimation { isLoading = false }
                }
            } catch {
                await MainActor.run {
                    withAnimation { isLoading = false }

                    let nsError = error as NSError
                    if nsError.domain == "com.google.GIDSignIn" && nsError.code == -5 {
                        print("[LoginView] Google sign-in cancelled by user")
                        return
                    }

                    print("[LoginView] Google sign-in failed: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func signInWithApple() {
        print("[LoginView] Apple sign-in initiated")
        withAnimation { isLoading = true }
        Task {
            do {
                try await privilegeManager.signInWithApple()
                await MainActor.run {
                    print("[LoginView] Apple sign-in successful, transitioning to main app")
                    withAnimation { isLoading = false }
                }
            } catch {
                await MainActor.run {
                    withAnimation { isLoading = false }

                    let nsError = error as NSError
                    if nsError.domain == "com.apple.AuthenticationServices.AuthorizationError" && nsError.code == 1000 {
                        print("[LoginView] Apple sign-in cancelled by user")
                        return
                    }

                    print("[LoginView] Apple sign-in failed: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func signInWithDevelopmentBypass() {
        print("[LoginView] Development bypass initiated")
        privilegeManager.signInWithDevelopmentBypass()
    }
}

// MARK: - View Extensions

extension View {
    /// Applies glass effect on macOS 26.0+ for modern Liquid Glass design
    /// Falls back to default styling on older OS versions
    @ViewBuilder
    func applyGlassEffect() -> some View {
        if #available(macOS 26.0, iOS 26.0, *) {
            self.glassEffect()
        } else {
            self
        }
    }
}

#Preview {
    LoginView(privilegeManager: PrivilegeManager.shared)
}
