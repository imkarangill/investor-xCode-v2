//
//  InvestorApp.swift
//  Investor
//
//  Created for xCode-v2 rewrite
//

import SwiftUI
import SwiftData

#if canImport(FirebaseCore)
import FirebaseCore
#endif

@main
struct InvestorApp: App {
    @StateObject private var stockListService = StockListService.shared
    @StateObject private var privilegeManager = PrivilegeManager.shared

    init() {
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            if !privilegeManager.isAuthenticated {
                // State 1: Not authenticated
                LoginView(privilegeManager: privilegeManager)
                    .transition(.opacity)
            } else if privilegeManager.needsSubscriptionFlow {
                // State 2: Authenticated but needs subscription flow
                SubscriptionOfferView()
                    .transition(.opacity)
            } else {
                // State 3: Authenticated and completed subscription flow
                ContentView()
                    .task {
                        await stockListService.initialize()
                    }
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
