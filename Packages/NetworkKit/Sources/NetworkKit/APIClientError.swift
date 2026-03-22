import Foundation

/// Errors that can be thrown by ``APIClient``.
public enum APIClientError: Error, Equatable {
    /// The response could not be cast to an HTTP response.
    case invalidResponse
    /// The request URL could not be built.
    case invalidURL
    /// The server responded with an unexpected status code.
    case unexpectedStatusCode(Int)
}
