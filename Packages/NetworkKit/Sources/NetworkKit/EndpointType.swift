import Foundation

/// Describes the information needed to build an API request.
public protocol EndpointType: Sendable {
    /// Headers to include with the request.
    var headers: [String: String] { get }
    /// The HTTP method for the request.
    var method: HTTPMethod { get }
    /// The path appended to the client's base URL.
    var path: String { get }
    /// Query items appended to the request URL.
    var queryItems: [URLQueryItem] { get }
}

public extension EndpointType {
    /// Default request headers.
    var headers: [String: String] { [:] }
    /// The default HTTP method.
    var method: HTTPMethod { .get }
    /// Default query items.
    var queryItems: [URLQueryItem] { [] }
}
