//
//  StockLogoImage.swift
//  Investor
//
//  Reusable async image loader for stock logos
//

import SwiftUI

struct StockLogoImage: View {
    let imageUrl: String?
    let symbol: String
    let size: CGFloat

    var body: some View {
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Circle()
                        .fill(.blue.opacity(0.2))
                        .frame(width: size, height: size)
                        .overlay {
                            ProgressView()
                                .scaleEffect(0.6)
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .clipShape(Rectangle())
                case .failure:
                    Circle()
                        .fill(.blue.opacity(0.2))
                        .frame(width: size, height: size)
                        .overlay {
                            Text(String(symbol.prefix(1)))
                                .font(.system(size: size * 0.4, weight: .semibold))
                                .foregroundStyle(.blue)
                        }
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Circle()
                .fill(.blue.opacity(0.2))
                .frame(width: size, height: size)
                .overlay {
                    Text(String(symbol.prefix(1)))
                        .font(.system(size: size * 0.4, weight: .semibold))
                        .foregroundStyle(.blue)
                }
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        StockLogoImage(imageUrl: "https://images.financialmodelingprep.com/symbol/AAPL.png", symbol: "AAPL", size: 40)
        StockLogoImage(imageUrl: nil, symbol: "TSLA", size: 40)
        StockLogoImage(imageUrl: "https://invalid.url/image.png", symbol: "MSFT", size: 50)
    }
    .padding()
}
