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
        HStack(alignment: .top) {
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
                }
                .buttonStyle(.plain)

                if tab != StockTab.allCases.last {
                    Divider().bold()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 10, alignment: .topLeading)
        .padding()
        .glassEffect(.regular.interactive(), in: .capsule)
    }
}

#Preview {
    StockTabs()
}
