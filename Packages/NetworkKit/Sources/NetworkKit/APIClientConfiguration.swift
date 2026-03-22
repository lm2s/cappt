import Foundation

/// The configuration used to create an ``APIClient``.
public struct APIClientConfiguration: Sendable, Equatable {
    /// The base URL used to build requests.
    public let baseURL: URL

    /// Creates a configuration with a base URL.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}
