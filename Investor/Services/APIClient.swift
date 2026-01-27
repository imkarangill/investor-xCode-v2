//
//  APIClient.swift
//  Investor
//
//  Network layer for investor-api-service
//

import Foundation

actor APIClient {
    static let shared = APIClient()

    // MARK: - Configuration

    private let baseURL = "https://investor-api-service-production.up.railway.app"
    private let apiVersion = "v1"

    // Note: In production, this should be stored securely (e.g., Keychain)
    // For development, you can set this via environment variable or config file
    private var userKey: String {
        ProcessInfo.processInfo.environment["INVESTOR_ADMIN_KEY"] ?? ""
    }

    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Init

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
    }

    // MARK: - Public API

    /// Fetch stock overview data
    func fetchStockOverview(symbol: String) async throws -> StockOverview {
        let endpoint = "/api/\(apiVersion)/stock/\(symbol.uppercased())/overview"
        return try await fetch(endpoint: endpoint)
    }

    /// Fetch list of all stocks for a country
    func fetchStockList(country: String = "US") async throws -> [StockListItem] {
        let endpoint = "/api/\(apiVersion)/stock/list?country=\(country)"
        return try await fetch(endpoint: endpoint)
    }

    /// Search for stocks (placeholder - implement when endpoint available)
    func searchStocks(query: String) async throws -> [StockProfile] {
        // TODO: Implement search endpoint when available
        // For now, return empty array
        return []
    }

    // MARK: - Private Methods

    private func fetch<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIClientError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(userKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIClientError.decodingError(error)
            }

        case 401:
            throw APIClientError.unauthorized

        case 403:
            throw APIClientError.forbidden

        case 404:
            throw APIClientError.notFound

        case 500...599:
            throw APIClientError.serverError(httpResponse.statusCode)

        default:
            throw APIClientError.httpError(httpResponse.statusCode)
        }
    }
}

// MARK: - API Client Error

enum APIClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)
    case httpError(Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please check your API key."
        case .forbidden:
            return "Access forbidden. You may have reached the rate limit or don't have permission for this resource."
        case .notFound:
            return "Stock not found"
        case .serverError(let code):
            return "Server error (\(code))"
        case .httpError(let code):
            return "HTTP error (\(code))"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
