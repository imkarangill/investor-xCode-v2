//
//  SubscriptionOfferView.swift
//  Investor
//
//  Subscription offer page shown to new free users after login
//

import SwiftUI

struct SubscriptionOfferView: View {
    @StateObject private var privilegeManager = PrivilegeManager.shared
    @State private var selectedTier: PrivilegeLevel = .free

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: AppTheme.Spacing.xs) {
                Text("Choose Your Plan")
                    .font(AppTheme.Typography.title1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Start with Free, upgrade anytime")
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(AppTheme.Spacing.lg)

            // Tiers
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppTheme.Spacing.md) {
                    SubscriptionTierCard(
                        tier: .free,
                        isSelected: selectedTier == .free
                    )
                    .onTapGesture {
                        withAnimation(AppTheme.Animation.quick) {
                            selectedTier = .free
                        }
                    }

                    SubscriptionTierCard(
                        tier: .pro,
                        isSelected: selectedTier == .pro
                    )
                    .onTapGesture {
                        withAnimation(AppTheme.Animation.quick) {
                            selectedTier = .pro
                        }
                    }

                    SubscriptionTierCard(
                        tier: .max,
                        isSelected: selectedTier == .max
                    )
                    .onTapGesture {
                        withAnimation(AppTheme.Animation.quick) {
                            selectedTier = .max
                        }
                    }
                }
                .padding(AppTheme.Spacing.lg)
            }

            Spacer()

            // Buttons
            VStack(spacing: AppTheme.Spacing.sm) {
                // Primary button
                Button(action: completeSubscriptionFlow) {
                    Text("Continue with Free")
                        .frame(maxWidth: 300)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .capsule)

                // Secondary button
                Button(action: completeSubscriptionFlow) {
                    Text("Maybe Later")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
            }
            .padding(AppTheme.Spacing.lg)
        }
        .background(.background)
        .ignoresSafeArea(edges: .bottom)
    }

    private func completeSubscriptionFlow() {
        privilegeManager.completeSubscriptionFlow()
    }
}

#Preview {
    SubscriptionOfferView()
}
