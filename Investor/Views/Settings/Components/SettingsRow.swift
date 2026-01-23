//
//  SettingsRow.swift
//  Investor
//
//  Reusable settings row component
//

import SwiftUI

struct SettingsRow: View {
    let label: String
    var value: String? = nil
    var showChevron: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: AppTheme.Spacing.md) {
                Text(label)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(.primary)

                Spacer()

                if let value = value {
                    Text(value)
                        .font(AppTheme.Typography.subheadline)
                        .foregroundStyle(.secondary)
                }

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        SettingsRow(label: "Email", value: "user@example.com")
        Divider()
        SettingsRow(label: "Notifications", value: "On", showChevron: true) {
            print("Tapped")
        }
        Divider()
        SettingsRow(label: "About", showChevron: true) {
            print("Tapped")
        }
    }
    .glassEffect()
    .padding()
}
