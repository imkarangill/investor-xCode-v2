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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: []) // Add SwiftData models here when needed

        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
