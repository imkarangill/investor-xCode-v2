//
//  ContentView.swift
//  Investor
//
//  Created for xCode-v2 rewrite
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var selectedSymbol: String?

    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            sidebarContent
                .navigationSplitViewColumnWidth(min: 200, ideal: 220)
        } detail: {
            detailContent
        }
        #else
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: .home) {
                NavigationStack {
                    HomeView()
                }
            }

            Tab("Search", systemImage: "magnifyingglass", value: .search) {
                NavigationStack {
                    SearchView(selectedSymbol: $selectedSymbol)
                }
            }
        }
        .tabViewStyle(.tabBarOnly)
        #endif
    }

    #if os(macOS)
    private var sidebarContent: some View {
        List(selection: $selectedTab) {
            NavigationLink(value: AppTab.home) {
                Label("Home", systemImage: "house")
            }

            NavigationLink(value: AppTab.search) {
                Label("Search", systemImage: "magnifyingglass")
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Investor")
    }

    @ViewBuilder
    private var detailContent: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .search:
            SearchView(selectedSymbol: $selectedSymbol)
        }
    }
    #endif
}

enum AppTab: Hashable {
    case home
    case search
}

#Preview {
    ContentView()
}
