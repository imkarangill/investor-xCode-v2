//
//  StockSearchViewModel.swift
//  Investor
//
//  ViewModel for stock search with suggestions and keyboard navigation
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class StockSearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var suggestions: [StockListItem] = []
    @Published var selectedSuggestionIndex: Int = -1

    private let stockListService = StockListService.shared

    enum NavigationDirection {
        case up, down
    }

    // MARK: - Search Logic

    /// Update search suggestions based on query
    func updateSearchSuggestions(for query: String) {
        guard !query.isEmpty else {
            suggestions = []
            selectedSuggestionIndex = -1
            return
        }

        let lowercasedQuery = query.lowercased()

        // Filter stocks with smart matching:
        // 1. Symbol starts with query (TWLO matches "TW")
        // 2. Symbol contains query (NFLX matches "FLX")
        // 3. Company name word starts with query (Meta Platforms matches "meta")

        let allMatches = stockListService.stocks.compactMap { stock -> (stock: StockListItem, priority: Int)? in
            let symbolLower = stock.symbol.lowercased()
            let nameLower = stock.companyName?.lowercased() ?? ""

            // Priority 1: Symbol starts with query (best match)
            if symbolLower.hasPrefix(lowercasedQuery) {
                return (stock, 1)
            }

            // Priority 2: Symbol contains query
            if symbolLower.contains(lowercasedQuery) {
                return (stock, 2)
            }

            // Priority 3: Company name word starts with query
            let nameWords = nameLower.split(separator: " ")
            for word in nameWords {
                if word.hasPrefix(lowercasedQuery) {
                    return (stock, 3)
                }
            }

            return nil
        }

        // Sort by priority, then alphabetically
        suggestions = allMatches
            .sorted { match1, match2 in
                if match1.priority != match2.priority {
                    return match1.priority < match2.priority
                }
                return match1.stock.symbol < match2.stock.symbol
            }
            .prefix(10)
            .map { $0.stock }

        // Reset selection when suggestions change
        selectedSuggestionIndex = -1
    }

    // MARK: - Keyboard Navigation

    /// Navigate suggestions with keyboard arrows
    func navigateSuggestions(direction: NavigationDirection) {
        guard !suggestions.isEmpty else { return }

        switch direction {
        case .down:
            if selectedSuggestionIndex < suggestions.count - 1 {
                selectedSuggestionIndex += 1
            }
        case .up:
            if selectedSuggestionIndex > 0 {
                selectedSuggestionIndex -= 1
            } else if selectedSuggestionIndex == -1 {
                selectedSuggestionIndex = suggestions.count - 1
            }
        }
    }

    /// Get currently selected suggestion
    func getSelectedSuggestion() -> StockListItem? {
        guard selectedSuggestionIndex >= 0 && selectedSuggestionIndex < suggestions.count else {
            return suggestions.first
        }
        return suggestions[selectedSuggestionIndex]
    }

    /// Clear search and reset state
    func clearSearch() {
        searchText = ""
        suggestions = []
        selectedSuggestionIndex = -1
    }
}
