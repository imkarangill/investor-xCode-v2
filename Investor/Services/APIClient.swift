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

    // Get Firebase ID token from Keychain for authentication
    private var authToken: String? {
        KeychainManager.shared.getAuthToken()
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

        guard let token = authToken else {
            throw APIClientError.unauthorized(message: "No authentication token found. Please sign in.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
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

        case 400:
            let errorMessage = extractErrorMessage(from: data) ?? "Invalid request"
            throw APIClientError.badRequest(message: errorMessage)

        case 401:
            throw APIClientError.unauthorized(message: "Authentication failed. Please sign in again.")

        case 403:
            let errorMessage = extractErrorMessage(from: data) ?? "Access forbidden"
            throw APIClientError.forbidden(message: errorMessage)

        case 404:
            throw APIClientError.notFound

        case 500...599:
            throw APIClientError.serverError(httpResponse.statusCode)

        default:
            throw APIClientError.httpError(httpResponse.statusCode)
        }
    }

    private func extractErrorMessage(from data: Data) -> String? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let detail = json["detail"] as? String {
                return detail
            }
        } catch {
            // Fall back to trying APIError struct
            if let error = try? decoder.decode(APIError.self, from: data) {
                return error.error
            }
        }
        return nil
    }
}

// MARK: - API Client Error

enum APIClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case badRequest(message: String)
    case unauthorized(message: String)
    case forbidden(message: String)
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
        case .badRequest(let message):
            return "Bad request: \(message)"
        case .unauthorized(let message):
            return message
        case .forbidden(let message):
            return message
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
