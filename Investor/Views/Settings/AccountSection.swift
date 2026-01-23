//
//  AccountSection.swift
//  Investor
//
//  Account section in Settings view
//

import SwiftUI

struct AccountSection: View {
    @ObservedObject var privilegeManager: PrivilegeManager
    @State private var isExpanded = true
    @State private var showSignOutAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            CategoryHeader(title: "ACCOUNT", isExpanded: $isExpanded)

            if isExpanded {
                if privilegeManager.isAuthenticated, let user = privilegeManager.currentUser {
                    // Authenticated state
                    VStack(spacing: 0) {
                        UserProfileRow(user: user)

                        Divider()
                            .padding(.horizontal, AppTheme.Spacing.md)

                        // Subscription row
                        HStack(spacing: AppTheme.Spacing.md) {
                            Text("Subscription")
                                .font(AppTheme.Typography.body)
                                .foregroundStyle(.primary)

                            Spacer()

                            SubscriptionBadge(privilegeLevel: user.privilegeLevel)

                            if let expiryDate = user.subscriptionExpiryDate {
                                Text("Expires \(formatDate(expiryDate))")
                                    .font(AppTheme.Typography.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)

                        Divider()
                            .padding(.horizontal, AppTheme.Spacing.md)

                        // Sign out button
                        Button {
                            showSignOutAlert = true
                        } label: {
                            HStack {
                                Text("Sign Out")
                                    .font(AppTheme.Typography.body)
                                    .foregroundStyle(.red)

                                Spacer()

                                Image(systemName: "arrow.right.square")
                                    .foregroundStyle(.red)
                            }
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.sm)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    // Not authenticated state
                    Button {
                        privilegeManager.requireLogin()
                    } label: {
                        HStack {
                            Text("Sign In")
                                .font(AppTheme.Typography.bodyEmphasized)
                                .foregroundStyle(.blue)

                            Spacer()

                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundStyle(.blue)
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .animation(AppTheme.Animation.quick, value: isExpanded)
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                privilegeManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview("Authenticated") {
    AccountSection(privilegeManager: PrivilegeManager.shared)
        .glassEffect()
        .padding()
}

#Preview("Not Authenticated") {
    struct PreviewWrapper: View {
        @StateObject private var manager = PrivilegeManager.shared

        var body: some View {
            AccountSection(privilegeManager: manager)
                .glassEffect()
                .padding()
                .onAppear {
                    manager.signOut()
                }
        }
    }

    return PreviewWrapper()
}
