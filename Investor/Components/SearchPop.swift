//
//  SearchPop.swift
//  Investor
//
//  Glass effect search popup component with search suggestions
//

import SwiftUI

struct Country: Identifiable, Equatable {
    let code: String
    let name: String
    var id: String { code }
}

struct SearchPop: View {
    @Binding var isPresented: Bool
    @Binding var searchText: String
    @FocusState private var isKeyboardActive: Bool
    @StateObject private var viewModel = StockSearchViewModel()
    @AppStorage("selectedCountryCode") private var selectedCountryCode: String = "US"

    @State private var localSearchText: String = ""
    @State private var showMarketSelection: Bool = false

    var onSearch: (String) -> Void

    // Countries list
    private let countries: [Country] = [
        .init(code: "AE", name: "United Arab Emirates"),
        .init(code: "AI", name: "Anguilla"),
        .init(code: "AR", name: "Argentina"),
        .init(code: "AT", name: "Austria"),
        .init(code: "AU", name: "Australia"),
        .init(code: "AZ", name: "Azerbaijan"),
        .init(code: "BB", name: "Barbados"),
        .init(code: "BE", name: "Belgium"),
        .init(code: "BG", name: "Bulgaria"),
        .init(code: "BM", name: "Bermuda"),
        .init(code: "BR", name: "Brazil"),
        .init(code: "BS", name: "Bahamas"),
        .init(code: "CA", name: "Canada"),
        .init(code: "CH", name: "Switzerland"),
        .init(code: "CI", name: "Côte d'Ivoire"),
        .init(code: "CL", name: "Chile"),
        .init(code: "CN", name: "China"),
        .init(code: "CO", name: "Colombia"),
        .init(code: "CR", name: "Costa Rica"),
        .init(code: "CW", name: "Curaçao"),
        .init(code: "CY", name: "Cyprus"),
        .init(code: "CZ", name: "Czech Republic"),
        .init(code: "DE", name: "Germany"),
        .init(code: "DK", name: "Denmark"),
        .init(code: "DO", name: "Dominican Republic"),
        .init(code: "EE", name: "Estonia"),
        .init(code: "EG", name: "Egypt"),
        .init(code: "ES", name: "Spain"),
        .init(code: "FI", name: "Finland"),
        .init(code: "FK", name: "Falkland Islands"),
        .init(code: "FR", name: "France"),
        .init(code: "GB", name: "United Kingdom"),
        .init(code: "GE", name: "Georgia"),
        .init(code: "GG", name: "Guernsey"),
        .init(code: "GI", name: "Gibraltar"),
        .init(code: "GR", name: "Greece"),
        .init(code: "HK", name: "Hong Kong"),
        .init(code: "HU", name: "Hungary"),
        .init(code: "ID", name: "Indonesia"),
        .init(code: "IE", name: "Ireland"),
        .init(code: "IL", name: "Israel"),
        .init(code: "IM", name: "Isle of Man"),
        .init(code: "IN", name: "India"),
        .init(code: "IS", name: "Iceland"),
        .init(code: "IT", name: "Italy"),
        .init(code: "JE", name: "Jersey"),
        .init(code: "JO", name: "Jordan"),
        .init(code: "JP", name: "Japan"),
        .init(code: "KH", name: "Cambodia"),
        .init(code: "KR", name: "South Korea"),
        .init(code: "KY", name: "Cayman Islands"),
        .init(code: "KZ", name: "Kazakhstan"),
        .init(code: "LI", name: "Liechtenstein"),
        .init(code: "LT", name: "Lithuania"),
        .init(code: "LU", name: "Luxembourg"),
        .init(code: "MC", name: "Monaco"),
        .init(code: "ME", name: "Montenegro"),
        .init(code: "MK", name: "North Macedonia"),
        .init(code: "MN", name: "Mongolia"),
        .init(code: "MO", name: "Macau"),
        .init(code: "MT", name: "Malta"),
        .init(code: "MU", name: "Mauritius"),
        .init(code: "MX", name: "Mexico"),
        .init(code: "MY", name: "Malaysia"),
        .init(code: "NA", name: "Namibia"),
        .init(code: "NG", name: "Nigeria"),
        .init(code: "NL", name: "Netherlands"),
        .init(code: "NO", name: "Norway"),
        .init(code: "NZ", name: "New Zealand"),
        .init(code: "PA", name: "Panama"),
        .init(code: "PE", name: "Peru"),
        .init(code: "PG", name: "Papua New Guinea"),
        .init(code: "PH", name: "Philippines"),
        .init(code: "PL", name: "Poland"),
        .init(code: "PR", name: "Puerto Rico"),
        .init(code: "PT", name: "Portugal"),
        .init(code: "RO", name: "Romania"),
        .init(code: "RU", name: "Russia"),
        .init(code: "SE", name: "Sweden"),
        .init(code: "SG", name: "Singapore"),
        .init(code: "SK", name: "Slovakia"),
        .init(code: "SR", name: "Suriname"),
        .init(code: "TC", name: "Turks and Caicos Islands"),
        .init(code: "TH", name: "Thailand"),
        .init(code: "TR", name: "Turkey"),
        .init(code: "TW", name: "Taiwan"),
        .init(code: "TZ", name: "Tanzania"),
        .init(code: "UA", name: "Ukraine"),
        .init(code: "US", name: "United States"),
        .init(code: "UY", name: "Uruguay"),
        .init(code: "VG", name: "British Virgin Islands"),
        .init(code: "VN", name: "Vietnam"),
        .init(code: "ZA", name: "South Africa")
    ]

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

                if showMarketSelection {
                    marketSelectionView
                } else {
                    searchView
                }
            }
        }
        .animation(.smooth(duration: 0.3), value: isPresented)
        .animation(.smooth(duration: 0.25), value: showMarketSelection)
        .onChange(of: isPresented) { _, newValue in
            if newValue {
                // Auto-focus keyboard when popup appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isKeyboardActive = true
                }
            } else {
                localSearchText = ""
                viewModel.clearSearch()
                showMarketSelection = false
            }
        }
        .onChange(of: selectedCountryCode) { _, newCountryCode in
            // Reload stock list when country changes
            Task {
                await StockListService.shared.fetchStocksForCountry(newCountryCode)
            }
        }
    }

    // MARK: - Search View

    private var searchView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Search bar
            HStack(spacing: AppTheme.Spacing.sm) {
                // Globe icon
                Button {
                    withAnimation(.smooth(duration: 0.25)) {
                        showMarketSelection = true
                        isKeyboardActive = false
                    }
                } label: {
                    Text(flagEmoji(selectedCountryCode))
                        .font(.title2)
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                .buttonStyle(.plain)

                // Search field
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "magnifyingglass")
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    TextField("Search stocks, ETFs...", text: $localSearchText)
                        .textFieldStyle(.plain)
                        .submitLabel(.search)
                        #if !os(macOS)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.asciiCapable)
                        #endif
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
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .frame(height: 44)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )

                // Close button (X)
                Button {
                    dismissPopup()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.md)

            // Suggestions list
            if !viewModel.suggestions.isEmpty && isKeyboardActive {
                searchSuggestionsView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, AppTheme.Spacing.md)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Market Selection View

    private var marketSelectionView: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            // Header with title and close button
            HStack {
                Text("Markets")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    withAnimation(.smooth(duration: 0.25)) {
                        showMarketSelection = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(.red)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.md)

            // Countries list
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    ForEach(countries) { country in
                        Button {
                            selectedCountryCode = country.code
                            withAnimation(.smooth(duration: 0.25)) {
                                showMarketSelection = false
                            }
                        } label: {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                // Flag badge
                                Text(flagEmoji(country.code))
                                    .font(.title3)
                                    .frame(width: 34, height: 34)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                    )

                                // Country name
                                Text(country.name)
                                    .font(.system(size: 15))
                                    .foregroundStyle(.primary)

                                Spacer()

                                // Radio indicator
                                Image(systemName: selectedCountryCode == country.code ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(selectedCountryCode == country.code ? .blue : .secondary)
                            }
                            .padding(.horizontal, AppTheme.Spacing.md)
                            .padding(.vertical, AppTheme.Spacing.sm)
                            .background(
                                Rectangle()
                                    .fill(selectedCountryCode == country.code ? .blue.opacity(0.1) : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)

                        if country != countries.last {
                            Divider()
                                .padding(.leading, AppTheme.Spacing.md + 34 + AppTheme.Spacing.sm)
                        }
                    }
                }
            }
            .padding(.bottom, AppTheme.Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, AppTheme.Spacing.md)
        .transition(.scale.combined(with: .opacity))
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
                                // Stock logo
                                if let imageUrl = stock.image, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            Circle()
                                                .fill(.blue.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                                .overlay {
                                                    ProgressView()
                                                        .scaleEffect(0.6)
                                                }
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 40, height: 40)
                                                .clipShape(Circle())
                                        case .failure:
                                            Circle()
                                                .fill(.blue.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                                .overlay {
                                                    Text(String(stock.symbol.prefix(1)))
                                                        .font(.system(size: 16, weight: .semibold))
                                                        .foregroundStyle(.blue)
                                                }
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    // Fallback when no image URL
                                    Circle()
                                        .fill(.blue.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                        .overlay {
                                            Text(String(stock.symbol.prefix(1)))
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(.blue)
                                        }
                                }

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
            showMarketSelection = false
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
