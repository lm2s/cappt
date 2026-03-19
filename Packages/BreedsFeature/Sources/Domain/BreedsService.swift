import BreedDetails
import ComposableArchitecture
import Foundation
import NetworkKit

public struct BreedsService: Sendable {
    public var fetchBreeds: @Sendable () async throws -> [Breed]

    public init(fetchBreeds: @escaping @Sendable () async throws -> [Breed]) {
        self.fetchBreeds = fetchBreeds
    }
}

public extension BreedsService {
    static func live(apiClient: APIClient) -> Self {
        Self {
            let (data, _) = try await apiClient.data(for: BreedsEndpoint.breeds())
            let response = try JSONDecoder().decode([BreedResponse].self, from: data)
            return response.map(\.breed)
        }
    }
}

extension BreedsService: TestDependencyKey {
    public static var previewValue: Self {
        Self(fetchBreeds: { Breed.mock })
    }

    public static var testValue: Self {
        Self(fetchBreeds: { [] })
    }
}

extension BreedsService: DependencyKey {
    public static var liveValue: Self {
        Self.live(
            apiClient: APIClient(
                configuration: APIClientConfiguration(
                    baseURL: URL(string: "https://api.thecatapi.com/v1")!
                )
            )
        )
    }
}

public extension DependencyValues {
    var breedsService: BreedsService {
        get { self[BreedsService.self] }
        set { self[BreedsService.self] = newValue }
    }
}

public enum BreedsEndpoint: EndpointType {
    case breeds(limit: Int? = nil, page: Int? = nil)

    public var path: String { "breeds" }

    public var queryItems: [URLQueryItem] {
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

private struct BreedResponse: Decodable, Sendable {
    let description: String?
    let id: String
    let name: String
    let origin: String?
    let referenceImageID: String?
    let temperament: String?

    enum CodingKeys: String, CodingKey {
        case description
        case id
        case name
        case origin
        case referenceImageID = "reference_image_id"
        case temperament
    }

    var breed: Breed {
        Breed(
            description: self.description ?? "",
            id: self.id,
            imageURL: self.referenceImageID.map(Self.imageURL(for:)) ?? "",
            isFavorite: false,
            name: self.name,
            origin: self.origin ?? "",
            temperament: self.temperament ?? ""
        )
    }

    private static func imageURL(for referenceImageID: String) -> String {
        "https://cdn2.thecatapi.com/images/\(referenceImageID).jpg"
    }
}
