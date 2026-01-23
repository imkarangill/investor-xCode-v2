//
//  SettingsView.swift
//  Investor
//
//  Created by Karan Gill on 1/21/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var privilegeManager = PrivilegeManager.shared
    @AppStorage("appTheme") private var selectedTheme: String = AppThemePreference.system.rawValue

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.lg) {
                    AccountSection(privilegeManager: privilegeManager)

                    Divider()
                        .padding(.horizontal, AppTheme.Spacing.md)

                    ThemeSection()
                }
                .padding(AppTheme.Spacing.md)
                .glassEffect()
                .padding(AppTheme.Spacing.md)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $privilegeManager.showLoginSheet) {
                LoginView(privilegeManager: privilegeManager)
            }
        }
    }
}

#Preview {
    SettingsView()
}
