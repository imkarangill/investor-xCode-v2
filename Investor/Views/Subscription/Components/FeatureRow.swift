//
//  FeatureRow.swift
//  Investor
//
//  Simple feature list item with icon and text
//

import SwiftUI

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(.green)
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    FeatureRow(icon: "checkmark.circle.fill", text: "Feature example")
}
