import Foundation

public enum APIClientError: Error, Equatable {
    case invalidResponse
    case invalidURL
    case unexpectedStatusCode(Int)
}
