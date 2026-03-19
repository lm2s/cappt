import Foundation
import Testing

@testable import NetworkKit

@Suite(.serialized)
struct APIClientTests {
    @Test
    func requestUsesBaseURLAndQueryItems() throws {
        let client = APIClient(configuration: APIClientConfiguration(baseURL: URL(string: "https://example.com/api")!))
        let request = try client.request(for: TestEndpoint.breeds(limit: 10, page: 2))

        #expect(request.httpMethod == HTTPMethod.get.rawValue)
        #expect(request.url?.absoluteString == "https://example.com/api/breeds?limit=10&page=2")
    }

    @Test
    func dataThrowsForUnexpectedStatusCode() async {
        URLProtocolStub.handler = { _ in
            (
                HTTPURLResponse(
                    url: URL(string: "https://example.com/api/breeds")!,
                    statusCode: 500,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data("[]".utf8)
            )
        }
        
        defer { URLProtocolStub.handler = nil }

        let client = APIClient(
            configuration: APIClientConfiguration(baseURL: URL(string: "https://example.com/api")!),
            session: .stubbed
        )

        await #expect(throws: APIClientError.unexpectedStatusCode(500)) {
            _ = try await client.data(for: TestEndpoint.breeds())
        }
    }
}

private enum TestEndpoint: EndpointType {
    case breeds(limit: Int? = nil, page: Int? = nil)

    var path: String { "breeds" }

    var queryItems: [URLQueryItem] {
        switch self {
        case let .breeds(limit, page):
            return [
                URLQueryItem(name: "limit", value: limit.map(String.init)),
                URLQueryItem(name: "page", value: page.map(String.init)),
            ]
            .compactMap { item in
                guard item.value != nil else { return nil }
                return item
            }
        }
    }
}

private extension URLSession {
    static var stubbed: Self {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return Self(configuration: configuration)
    }
}

private final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var handler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            self.client?.urlProtocol(self, didFailWithError: APIClientError.invalidResponse)
            return
        }

        do {
            let (response, data) = try handler(self.request)
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
        } catch {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
