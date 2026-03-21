import ComposableArchitecture
import PersistenceKit
import Foundation
import NetworkKit

public struct BreedsService: Sendable {
    public var fetchBreeds: @Sendable () async throws -> [Breed]

    public init(fetchBreeds: @escaping @Sendable () async throws -> [Breed]) {
        self.fetchBreeds = fetchBreeds
    }
    
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

private struct BreedResponse: Decodable, Sendable {
    let description: String?
    let id: String
    let lifeSpan: String?
    let name: String
    let origin: String?
    let referenceImageID: String?
    let temperament: String?

    enum CodingKeys: String, CodingKey {
        case description
        case id
        case lifeSpan = "life_span"
        case name
        case origin
        case referenceImageID = "reference_image_id"
        case temperament
    }

    var breed: Breed {
        let parsedLifeSpan = Breed.parseLifeSpan(self.lifeSpan ?? "")
        return Breed(
            description: self.description ?? "",
            id: self.id,
            imageURL: self.referenceImageID.map(Self.imageURL(for:)) ?? "",
            isFavorite: false,
            lifeSpanLowerBound: parsedLifeSpan.lower,
            lifeSpanUpperBound: parsedLifeSpan.upper,
            name: self.name,
            origin: self.origin ?? "",
            temperament: self.temperament ?? ""
        )
    }

    private static func imageURL(for referenceImageID: String) -> String {
        "https://cdn2.thecatapi.com/images/\(referenceImageID).jpg"
    }
}
