//
//  SubscriptionBadge.swift
//  Investor
//
//  Colored badge showing privilege level
//

import SwiftUI

struct SubscriptionBadge: View {
    let privilegeLevel: PrivilegeLevel

    var body: some View {
        Text(privilegeLevel.rawValue)
            .font(AppTheme.Typography.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, AppTheme.Spacing.xxs)
            .background(badgeColor.gradient, in: Capsule())
    }

    private var badgeColor: Color {
        switch privilegeLevel {
        case .free:
            return .gray
        case .pro:
            return .blue
        case .max:
            return .purple
        case .ultimate:
            return .orange
        case .admin:
            return .red
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: AppTheme.Spacing.sm) {
        ForEach(PrivilegeLevel.allCases, id: \.self) { level in
            SubscriptionBadge(privilegeLevel: level)
        }
    }
    .padding()
}
