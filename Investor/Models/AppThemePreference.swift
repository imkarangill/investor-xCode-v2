//
//  AppThemePreference.swift
//  Investor
//
//  Theme preference management for light/dark mode
//

import SwiftUI

enum AppThemePreference: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
