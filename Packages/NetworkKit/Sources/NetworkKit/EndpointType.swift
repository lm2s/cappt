import Foundation

public protocol EndpointType: Sendable {
    var headers: [String: String] { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

public extension EndpointType {
    var headers: [String: String] { [:] }
    var method: HTTPMethod { .get }
    var queryItems: [URLQueryItem] { [] }
}
