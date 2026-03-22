import Foundation

/// A lightweight client for making requests to API endpoints.
public struct APIClient: Sendable {
    private let configuration: APIClientConfiguration
    private let session: URLSession
    
    /// Creates an API client with a base configuration and URL session.
    public init(
        configuration: APIClientConfiguration,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session
    }
    
    /// Fetches raw data and the URL response for an endpoint.
    public func data(for endpoint: some EndpointType) async throws -> (Data, URLResponse) {
        let request = try self.request(for: endpoint)
        let (data, response) = try await self.session.data(for: request)
        try self.validate(response)
        return (data, response)
    }
    
    func request(for endpoint: some EndpointType) throws -> URLRequest {
        let path = endpoint.path.hasPrefix("/") ? String(endpoint.path.dropFirst()) : endpoint.path
        let baseURL = self.configuration.baseURL.absoluteString
            .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let urlString = "\(baseURL)/\(path)"
        
        guard var components = URLComponents(
            string: urlString
        ) else {
            throw APIClientError.invalidURL
        }
        
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        
        guard let requestURL = components.url else {
            throw APIClientError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = endpoint.method.rawValue
        
        for (field, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
        
        return request
    }
    
    private func validate(_ response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse else {
            throw APIClientError.invalidResponse
        }
        
        guard (200..<300).contains(response.statusCode) else {
            throw APIClientError.unexpectedStatusCode(response.statusCode)
        }
    }
}
