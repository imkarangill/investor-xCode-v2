//
//  ThemeSection.swift
//  Investor
//
//  Theme selection section in Settings view
//

import SwiftUI

struct ThemeSection: View {
    @AppStorage("appTheme") private var selectedTheme: String = AppThemePreference.system.rawValue
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            CategoryHeader(title: "THEME", isExpanded: $isExpanded)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(AppThemePreference.allCases, id: \.self) { theme in
                        if theme != AppThemePreference.allCases.first {
                            Divider()
                                .padding(.horizontal, AppTheme.Spacing.md)
                        }

                        ThemePickerRow(
                            theme: theme,
                            isSelected: selectedTheme == theme.rawValue
                        ) {
                            print("[ThemeSection] Theme tapped: \(theme.rawValue)")
                            selectedTheme = theme.rawValue
                            print("[ThemeSection] Theme updated to: \(selectedTheme)")
                        }
                    }
                }
            }
        }
        .animation(AppTheme.Animation.quick, value: isExpanded)
    }

    private var currentTheme: AppThemePreference {
        AppThemePreference(rawValue: selectedTheme) ?? .system
    }
}

// MARK: - Preview

#Preview {
    ThemeSection()
        .glassEffect()
        .padding()
}
