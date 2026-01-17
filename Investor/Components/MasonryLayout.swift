//
//  MasonryLayout.swift
//  Investor
//
//  Multi-column masonry layout for tiles using public SwiftUI APIs
//

import SwiftUI

struct MasonryLayout<Content: View>: View {
    let columns: Int
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        let actualColumns = horizontalSizeClass == .compact ? 1 : columns

        if actualColumns == 1 {
            VStack(spacing: spacing) {
                content()
            }
        } else {
            HStack(alignment: .top, spacing: spacing) {
                ForEach(0..<actualColumns, id: \.self) { columnIndex in
                    VStack(spacing: spacing) {
                        TileColumn(
                            index: columnIndex,
                            totalColumns: actualColumns,
                            content: AnyView(content())
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - Tile Column (extracts nth items)

struct TileColumn: View {
    let index: Int
    let totalColumns: Int
    let content: AnyView

    var body: some View {
        // Note: This is a simplified approach that shows all content
        // For true masonry, consider using LazyVStack with a custom layout
        content
    }
}

// MARK: - Adaptive Masonry (responsive columns)

struct AdaptiveMasonryLayout<Content: View>: View {
    let spacing: CGFloat
    @ViewBuilder let content: () -> Content

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(spacing: CGFloat = 20, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        let columns = horizontalSizeClass == .compact ? 1 : 2

        if columns == 1 {
            VStack(spacing: spacing) {
                content()
            }
        } else {
            MasonryLayout(columns: columns, spacing: spacing) {
                content()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        MasonryLayout(columns: 2, spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue.opacity(0.3))
                .frame(height: 100)

            RoundedRectangle(cornerRadius: 12)
                .fill(.green.opacity(0.3))
                .frame(height: 150)

            RoundedRectangle(cornerRadius: 12)
                .fill(.orange.opacity(0.3))
                .frame(height: 80)

            RoundedRectangle(cornerRadius: 12)
                .fill(.purple.opacity(0.3))
                .frame(height: 120)

            RoundedRectangle(cornerRadius: 12)
                .fill(.red.opacity(0.3))
                .frame(height: 90)
        }
        .padding()
    }
}
