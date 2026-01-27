//
//  StockTabs.swift
//  Investor
//
//  Created by Karan Gill on 1/25/26.
//

import SwiftUI

struct StockTabs: View {
    enum StockTab: String, CaseIterable {
        case overview = "Overview"
        case statements = "Statements"
    }

    @State private var selectedTab: StockTab = .overview

    var body: some View {
        VStack(spacing: 12) {
            // Tab buttons with horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(StockTab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(AppTheme.Animation.quick) {
                                selectedTab = tab
                            }
                        } label: {
                            Text(tab.rawValue)
                                .font(.caption)
                                .foregroundStyle(selectedTab == tab ? .blue : .secondary)
                                .bold(selectedTab == tab)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.automatic)
                        .glassEffect(.regular.interactive(), in: .capsule)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .scrollContentBackground(.hidden)
        }
    }
}

#Preview {
    StockTabs()
}
