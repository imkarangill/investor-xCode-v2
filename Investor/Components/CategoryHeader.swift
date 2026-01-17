//
//  CategoryHeader.swift
//  Investor
//
//  Collapsible section header with chevron
//

import SwiftUI

struct CategoryHeader: View {
    let title: String
    @Binding var isExpanded: Bool

    var body: some View {
        Button {
            withAnimation(AppTheme.Animation.quick) {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                Text(title)
                    .font(AppTheme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, AppTheme.Spacing.xs)
            .padding(.horizontal, AppTheme.Spacing.xxs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var isExpanded1 = true
        @State private var isExpanded2 = false

        var body: some View {
            VStack(spacing: 0) {
                CategoryHeader(title: "Growth (Expanded)", isExpanded: $isExpanded1)

                if isExpanded1 {
                    Text("Expanded content here")
                        .font(.caption)
                        .padding()
                }

                Divider()

                CategoryHeader(title: "Returns (Collapsed)", isExpanded: $isExpanded2)

                if isExpanded2 {
                    Text("Hidden content")
                        .font(.caption)
                        .padding()
                }
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
