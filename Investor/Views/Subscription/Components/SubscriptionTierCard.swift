//
//  SubscriptionTierCard.swift
//  Investor
//
//  Card displaying subscription tier with price and CTA
//

import SwiftUI

struct SubscriptionTierCard: View {
    let tier: PrivilegeLevel
    var isSelected: Bool = false

    @State private var showComingSoonAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Tier badge and coming soon label
            HStack {
                SubscriptionBadge(privilegeLevel: tier)

                if tier != .free {
                    Text("COMING SOON")
                        .font(AppTheme.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            // Price
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(priceText)
                    .font(AppTheme.Typography.title2)
                    .fontWeight(.bold)

                if tier != .free {
                    Text("per month")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // CTA Button
            if tier != .free {
                Button(action: { showComingSoonAlert = true }) {
                    Text("Coming Soon")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .font(AppTheme.Typography.bodyEmphasized)
                }
                .buttonStyle(.plain)
                .disabled(true)
                .opacity(0.5)
            }
        }
        .padding(AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        }
        .alert("Coming Soon", isPresented: $showComingSoonAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Subscriptions will be available soon! Check back later.")
        }
    }

    private var priceText: String {
        switch tier {
        case .free:
            return "Free forever"
        case .pro:
            return "$4.99"
        case .max:
            return "$9.99"
        case .ultimate:
            return "$19.99"
        case .admin:
            return "Admin"
        }
    }
}

#Preview {
    VStack(spacing: AppTheme.Spacing.md) {
        SubscriptionTierCard(tier: .free, isSelected: true)
        SubscriptionTierCard(tier: .pro, isSelected: false)
        SubscriptionTierCard(tier: .max, isSelected: false)
    }
    .padding(AppTheme.Spacing.lg)
}
