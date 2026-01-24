//
//  ContentView.swift
//  Investor
//
//  Created for xCode-v2 rewrite
//

import SwiftUI

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var showSearchPopup: Bool = false
    @State private var currentView: String = "home"
    @State private var selectedStock: String? = nil
    @AppStorage("appTheme") private var selectedTheme: String = AppThemePreference.system.rawValue

    var body: some View {
        ZStack(alignment: .bottom) {
            if currentView == "home" {
                HomeView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if currentView == "stock", let symbol = selectedStock {
                StockOverviewView(service: StockService(), symbol: symbol)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                SettingsView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(selectedTheme)
            }

            VStack(spacing: 0) {
                Spacer()

                HStack(spacing: 12) {
                    // Left side navigation
                    if currentView == "stock" || currentView == "settings" {
                        // Only Home button for stock and settings views
                        Button {
                            currentView = "home"
                            selectedStock = nil
                        } label: {
                            Image(systemName: "house.fill")
                                .font(.title)
                                .foregroundStyle(.blue)
                                .frame(width: 50, height: 50)
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.regular.interactive(), in: .circle)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Home + Settings buttons for home view
                        HStack(spacing: 16) {
                            Button {
                                currentView = "home"
                                selectedStock = nil
                            } label: {
                                Image(systemName: "house.fill")
                                    .font(.title)
                                    .foregroundStyle(currentView == "home" ? .blue : .primary)
                            }
                            .buttonStyle(.plain)

                            Button {
                                currentView = "settings"
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.title)
                                    .foregroundStyle(currentView == "settings" ? .blue : .primary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 50)
                        .glassEffect(.regular.interactive(), in: .capsule)
                        .transition(.scale.combined(with: .opacity))
                    }

                    Spacer()

                    // Right side search button (for home and stock views only)
                    if currentView == "home" || currentView == "stock" {
                        Button {
                            showSearchPopup = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.title)
                                .frame(width: 50, height: 50)
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.regular.interactive(), in: .circle)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                .animation(.smooth(duration: 0.25), value: currentView)
            }
            .background {
                ConcentricRectangle(corners: .concentric, isUniform: true)
                    .fill(.black.opacity(0.001))
                    .allowsHitTesting(false)
            }
            .ignoresSafeArea()

            // Search popup overlay
            SearchPop(
                isPresented: $showSearchPopup,
                searchText: $searchText,
                onSearch: { symbol in
                    selectedStock = symbol
                    currentView = "stock"
                    showSearchPopup = false
                }
            )
        }
        .preferredColorScheme(currentTheme.colorScheme)
    }

    private var currentTheme: AppThemePreference {
        AppThemePreference(rawValue: selectedTheme) ?? .system
    }
}

#Preview {
    ContentView()
}
