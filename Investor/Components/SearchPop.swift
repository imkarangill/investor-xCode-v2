//
//  SearchPop.swift
//  Investor
//
//  Glass effect search popup component with search suggestions
//

import SwiftUI

struct SearchPop: View {
    @Binding var isPresented: Bool
    @Binding var searchText: String
    @FocusState private var isKeyboardActive: Bool
    @StateObject private var viewModel = StockSearchViewModel()

    @State private var localSearchText: String = ""

    var onSearch: (String) -> Void

    var body: some View {
        ZStack {
            if isPresented {
                // Semi-transparent background overlay
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissPopup()
                    }
                    .transition(.opacity)

                // Search popup with glass effect
                VStack(spacing: AppTheme.Spacing.md) {
                    // Search bar
                    HStack(spacing: AppTheme.Spacing.sm) {
                        // Globe icon
                        Button {
                            // Market selection action
                        } label: {
                            VStack (spacing: AppTheme.Spacing.xxxs){
                                Text(flagEmoji("US"))
                                    .font(.title2)
                                    .foregroundStyle(.primary)
                                    .frame(width: 44, height: 44)
                            }
                        }
                        .buttonStyle(.plain)
                        .background {
                            Circle()
                                .fill(.ultraThinMaterial)
                        }

                        // Search field
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Image(systemName: "magnifyingglass")
                                .font(.callout)
                                .foregroundStyle(.secondary)

                            TextField("Search stocks, ETFs...", text: $localSearchText)
                                .textFieldStyle(.plain)
                                .submitLabel(.search)
                                .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                                    .keyboardType(.asciiCapable)
                                .focused($isKeyboardActive)
                                .onChange(of: localSearchText) { _, newValue in
                                    viewModel.searchText = newValue
                                    viewModel.updateSearchSuggestions(for: newValue)
                                }
                                .onSubmit {
                                    if let stock = viewModel.getSelectedSuggestion() {
                                        handleStockSelection(stock)
                                    }
                                }
                                #if os(macOS)
                                .onKeyPress(.downArrow) {
                                    viewModel.navigateSuggestions(direction: .down)
                                    return .handled
                                }
                                .onKeyPress(.upArrow) {
                                    viewModel.navigateSuggestions(direction: .up)
                                    return .handled
                                }
                                .onKeyPress(.escape) {
                                    dismissPopup()
                                    return .handled
                                }
                                #endif
                        }
                        .padding(.horizontal, AppTheme.Spacing.md)
                        .frame(height: 44)
                        .background {
                            Capsule()
                                .fill(.ultraThinMaterial)
                        }

                        // Close button (X)
                        Button {
                            dismissPopup()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundStyle(.primary)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        .background {
                            Circle()
                                .fill(.ultraThinMaterial)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.md)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                    // Suggestions list
                    if !viewModel.suggestions.isEmpty && isKeyboardActive {
                        searchSuggestionsView
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.smooth(duration: 0.3), value: isPresented)
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                // Auto-focus keyboard when popup appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isKeyboardActive = true
                }
            } else {
                localSearchText = ""
                viewModel.clearSearch()
            }
        }
    }

    private var searchSuggestionsView: some View {
        let currentSuggestions = viewModel.suggestions // Capture once to avoid race conditions

        return ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    ForEach(currentSuggestions) { stock in
                        let index = currentSuggestions.firstIndex(where: { $0.id == stock.id }) ?? -1

                        Button(action: {
                            handleStockSelection(stock)
                        }) {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(stock.symbol)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(.primary)

                                    if let name = stock.companyName, !name.isEmpty {
                                        Text(name)
                                            .font(.system(size: 13))
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }

                                Spacer()

                                // Exchange indicator
                                if let exchange = stock.exchange {
                                    Text(exchange)
                                        .font(.system(size: 11))
                                        .foregroundStyle(.tertiary)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(.blue.opacity(0.15))
                                        .cornerRadius(4)
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.sm)
                            .background(
                                Rectangle()
                                    .fill(viewModel.selectedSuggestionIndex == index ? .blue.opacity(0.15) : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)
                        .id(stock.id)

                        if index < currentSuggestions.count - 1 {
                            Divider()
                                .padding(.leading, AppTheme.Spacing.md)
                        }
                    }
                }
                .onChange(of: viewModel.selectedSuggestionIndex) { _, newIndex in
                    if newIndex >= 0 && newIndex < currentSuggestions.count {
                        let selectedStock = currentSuggestions[newIndex]
                        withAnimation(.easeInOut(duration: 0.2)) {
                            proxy.scrollTo(selectedStock.id, anchor: .center)
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
            .padding(.bottom, AppTheme.Spacing.md)
        }
    }

    private func handleStockSelection(_ stock: StockListItem) {
        onSearch(stock.symbol)
        dismissPopup()
    }

    private func dismissPopup() {
        withAnimation(.smooth(duration: 0.25)) {
            isKeyboardActive = false
            isPresented = false
            searchText = ""
            localSearchText = ""
            viewModel.clearSearch()
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var searchText = ""

    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()

        SearchPop(
            isPresented: $isPresented,
            searchText: $searchText,
            onSearch: { query in
                print("Searching for: \(query)")
            }
        )
    }
}
