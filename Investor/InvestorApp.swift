//
//  InvestorApp.swift
//  Investor
//
//  Created for xCode-v2 rewrite
//

import SwiftUI
import SwiftData

@main
struct InvestorApp: App {
    @StateObject private var stockListService = StockListService.shared
    @StateObject private var privilegeManager = PrivilegeManager.shared

    var body: some Scene {
        WindowGroup {
            if privilegeManager.isAuthenticated {
                ContentView()
                    .task {
                        await stockListService.initialize()
                    }
                    .transition(.opacity)
            } else {
                LoginView(privilegeManager: privilegeManager)
                    .transition(.opacity)
            }
        }
        .modelContainer(for: []) // Add SwiftData models here when needed

        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
