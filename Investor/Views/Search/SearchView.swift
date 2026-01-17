//
//  SearchView.swift
//  Investor
//
//  Search screen
//

import SwiftUI

struct SearchView: View {
    @Binding var selectedSymbol: String?

    var body: some View {
        Text("Search")
    }
}

#Preview {
    NavigationStack {
        SearchView(selectedSymbol: .constant(nil))
    }
}
