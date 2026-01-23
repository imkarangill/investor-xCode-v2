//
//  UserProfileRow.swift
//  Investor
//
//  User profile row with avatar and details
//

import SwiftUI

struct UserProfileRow: View {
    let user: User

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Avatar with initials
            ZStack {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 48, height: 48)

                Text(initials)
                    .font(AppTheme.Typography.title3)
                    .foregroundStyle(.white)
            }

            // User info
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xxs) {
                if let name = user.name {
                    Text(name)
                        .font(AppTheme.Typography.bodyEmphasized)
                        .foregroundStyle(.primary)
                }

                Text(user.email)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
    }

    private var initials: String {
        if let name = user.name, !name.isEmpty {
            let components = name.split(separator: " ")
            if components.count >= 2 {
                let first = components[0].prefix(1)
                let last = components[1].prefix(1)
                return "\(first)\(last)".uppercased()
            } else {
                return String(name.prefix(2)).uppercased()
            }
        } else {
            // Use email initials as fallback
            return String(user.email.prefix(2)).uppercased()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppTheme.Spacing.md) {
        UserProfileRow(user: User(
            id: "1",
            email: "john.doe@example.com",
            name: "John Doe",
            privilegeLevel: .pro,
            subscriptionExpiryDate: nil,
            authProvider: .google
        ))

        UserProfileRow(user: User(
            id: "2",
            email: "dev@investor.app",
            name: nil,
            privilegeLevel: .admin,
            subscriptionExpiryDate: nil,
            authProvider: .development
        ))
    }
    .glassEffect()
    .padding()
}
