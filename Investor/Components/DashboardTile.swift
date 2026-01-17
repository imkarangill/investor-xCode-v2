//
//  DashboardTile.swift
//  Investor
//
//  Glass tile container for dashboard content
//

import SwiftUI

struct DashboardTile<Content: View>: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let showInfoButton: Bool
    let infoContent: AnyView?
    @ViewBuilder let content: () -> Content

    @State private var showInfo = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        showInfoButton: Bool = false,
        infoContent: AnyView? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.showInfoButton = showInfoButton
        self.infoContent = infoContent
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            // Header
            HStack(spacing: AppTheme.Spacing.xs) {
                Text(title)
                    .font(AppTheme.Typography.bodyEmphasized)

                Spacer()

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(AppTheme.Typography.caption2)
                        .foregroundStyle(.secondary)
                }

                if showInfoButton {
                    Button {
                        showInfo.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $showInfo) {
                        if let content = infoContent {
                            content
                                .padding()
                                .frame(width: 320)
                        }
                    }
                }
            }

            // Content
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(horizontalSizeClass == .compact ? AppTheme.Spacing.md : AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .glassEffect()
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        DashboardTile(title: "Growth", subtitle: "CAGR") {
            Text("Content goes here")
                .foregroundStyle(.secondary)
        }

        DashboardTile(
            title: "Returns",
            subtitle: "TTM",
            showInfoButton: true,
            infoContent: AnyView(Text("Info about returns"))
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Text("ROCE: 25%")
                Text("FCFROCE: 22%")
            }
            .font(AppTheme.Typography.caption)
        }
    }
    .padding()
}
