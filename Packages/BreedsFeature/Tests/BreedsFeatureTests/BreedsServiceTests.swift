import ComposableArchitecture
import CustomDump
import DependenciesTestSupport
import Foundation
import PersistenceKit
import NetworkKit
import Testing

@testable import BreedsFeature

struct BreedsServiceTests {
    @Test
    func fetchBreedsDecodesResponse() async throws {
        URLProtocolStub.handler = { _ in
            (
                HTTPURLResponse(
                    url: URL(string: "https://api.thecatapi.com/v1/breeds")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: nil
                )!,
                Data(
                    """
                    [
                      {
                        "id": "abys",
                        "name": "Abyssinian",
                        "description": "Curious and social",
                        "origin": "Egypt",
                        "temperament": "Active, Gentle",
                        "reference_image_id": "0XYvRd7oD"
                      }
                    ]
                    """.utf8
                )
            )
        }
        defer { URLProtocolStub.handler = nil }

        let service = BreedsService.live(
            apiClient: APIClient(
                configuration: APIClientConfiguration(
                    baseURL: URL(string: "https://api.thecatapi.com/v1")!
                ),
                session: .stubbed
            )
        )

        let breeds = try await service.fetchBreeds()

        expectNoDifference(
            breeds,
            [
                Breed(
                    description: "Curious and social",
                    id: "abys",
                    imageURL: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg",
                    isFavorite: false,
                    name: "Abyssinian",
                    origin: "Egypt",
                    temperament: "Active, Gentle"
                )
            ]
        )
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
            self.client?.urlProtocol(
                self,
                didFailWithError: URLError(.badServerResponse)
            )
            return
        }

        do {
            let (response, data) = try handler(self.request)
            self.client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
        } catch {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
