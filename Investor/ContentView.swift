//
//  ContentView.swift
//  Investor
//
//  Created for xCode-v2 rewrite
//

import SwiftUI

struct ContentView: View {
    @State private var searchText: String = ""
    @FocusState private var isKeyboardActive: Bool
    @State private var isSearchActive: Bool = false
    @State private var currentView: String = "home"

    var body: some View {
        ZStack(alignment: .bottom) {
            if currentView == "home" {
                HomeView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                SettingsView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            VStack(spacing: 0) {
                Spacer()

                HStack(spacing: 12) {
                    if isSearchActive {
                        // Search active state
                        Button {
                            // Market selection action
                        } label: {
                            Image(systemName: "globe")
                                .font(.title)
                                .frame(width: 50, height: 50)
                                .contentTransition(.symbolEffect)
                        }
                        .glassEffect(.regular.interactive(), in: .circle)

                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            TextField("Search stocks, ETFs...", text: $searchText)
                                .submitLabel(.search)
                                .focused($isKeyboardActive)
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 50)
                        .glassEffect(.regular.interactive(), in: .capsule)
                        .transition(.scale.combined(with: .opacity))

                        Button {
                            withAnimation(.smooth(duration: 0.25)) {
                                isSearchActive = false
                                isKeyboardActive = false
                                searchText = ""
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title)
                                .frame(width: 50, height: 50)
                                .contentTransition(.symbolEffect)
                        }
                        .glassEffect(.regular.interactive(), in: .circle)
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Default state
                        HStack(spacing: 16) {
                            Button {
                                currentView = "home"
                            } label: {
                                Image(systemName: "house.fill")
                                    .font(.title)
                                    .foregroundStyle(currentView == "home" ? .blue : .primary)
                            }

                            Button {
                                currentView = "settings"
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.title)
                                    .foregroundStyle(currentView == "settings" ? .blue : .primary)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(height: 50)
                        .glassEffect(.regular.interactive(), in: .capsule)
                        .transition(.scale.combined(with: .opacity))

                        Spacer()

                        if currentView == "home" {
                            Button {
                                withAnimation(.smooth(duration: 0.25)) {
                                    isSearchActive = true
                                    isKeyboardActive = true
                                }
                            } label: {
                                Image(systemName: "magnifyingglass")
                                    .font(.title)
                                    .frame(width: 50, height: 50)
                            }
                            .glassEffect(.regular.interactive(), in: .circle)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                .animation(.smooth(duration: 0.25), value: isSearchActive)
                .animation(.smooth(duration: 0.25), value: currentView)
            }
            .background {
                ConcentricRectangle(corners: .concentric, isUniform: true)
                    .fill(.black.opacity(0.001))
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
