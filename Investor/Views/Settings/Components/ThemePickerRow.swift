//
//  ThemePickerRow.swift
//  Investor
//
//  Radio button style theme picker row
//

import SwiftUI

struct ThemePickerRow: View {
    let theme: AppThemePreference
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.md) {
                // Radio button indicator
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.accentColor : Color.secondary, lineWidth: 2)
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 12, height: 12)
                    }
                }

                // Theme label
                Text(theme.rawValue)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(.primary)

                Spacer()

                // "Current" indicator
                if isSelected {
                    Text("Current")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        ThemePickerRow(theme: .system, isSelected: true) {
            print("System selected")
        }
        Divider()
        ThemePickerRow(theme: .light, isSelected: false) {
            print("Light selected")
        }
        Divider()
        ThemePickerRow(theme: .dark, isSelected: false) {
            print("Dark selected")
        }
    }
    .glassEffect()
    .padding()
}
