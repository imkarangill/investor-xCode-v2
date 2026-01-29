//
//  APIClient.swift
//  Investor
//
//  Network layer for investor-api-service
//

import Foundation
import os

#if canImport(FirebaseAuth)
import FirebaseAuth
#endif

actor APIClient {
    static let shared = APIClient()
    private static let logger = os.Logger(subsystem: "com.investor", category: "APIClient")

    // MARK: - Configuration

    private let baseURL = "https://investor-api-service-production.up.railway.app"
    private let apiVersion = "v1"

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

    /// Fetch home screen data (portfolio, watchlists, recently viewed)
    func fetchHome() async throws -> HomeResponse {
        let endpoint = "/api/\(apiVersion)/users/me/home"
        return try await fetch(endpoint: endpoint)
    }

    // MARK: - Private Methods

    /// Get fresh Firebase ID token, using cached token if still valid
    private func getFreshAuthToken() async throws -> String {
        #if canImport(FirebaseAuth)
        guard let user = Auth.auth().currentUser else {
            let errorMsg = "User not authenticated. Please sign in."
            Self.logger.error("Firebase user not found: \(errorMsg)")
            throw APIClientError.unauthorized(message: errorMsg)
        }

        do {
            // getIDToken() returns cached token if valid, refreshes if expired
            let token = try await user.getIDToken()
            return token
        } catch {
            let errorMsg = "Failed to get authentication token: \(error.localizedDescription)"
            Self.logger.error("Firebase token fetch failed: \(errorMsg)")
            throw APIClientError.unauthorized(message: errorMsg)
        }
        #else
        throw APIClientError.unauthorized(message: "Firebase not configured")
        #endif
    }

    private func fetch<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIClientError.invalidURL
        }

        let token = try await getFreshAuthToken()

        let tokenPreview = String(token.prefix(20)) + "..."
        Self.logger.debug("Making request to \(endpoint) with token: \(tokenPreview)")

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
                // Log the raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    Self.logger.error("Decoding failed for endpoint: \(endpoint)")
                    Self.logger.error("Response body: \(jsonString)")
                }
                Self.logger.error("Decoding error: \(error.localizedDescription)")
                throw APIClientError.decodingError(error)
            }

        case 400:
            let errorMessage = extractErrorMessage(from: data) ?? "Invalid request"
            throw APIClientError.badRequest(message: errorMessage)

        case 401:
            let errorMsg = extractErrorMessage(from: data) ?? "Authentication failed. Please sign in again."
            Self.logger.error("API returned 401 Unauthorized: \(errorMsg)")
            throw APIClientError.unauthorized(message: errorMsg)

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
