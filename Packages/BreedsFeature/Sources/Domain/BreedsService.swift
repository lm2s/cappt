import ComposableArchitecture
import PersistenceKit
import Foundation
import NetworkKit

public struct BreedsService: Sendable {
    public var fetchBreeds: @Sendable (_ limit: Int, _ page: Int) async throws -> [Breed]

    public init(fetchBreeds: @escaping @Sendable (_ limit: Int, _ page: Int) async throws -> [Breed]) {
        self.fetchBreeds = fetchBreeds
    }

    static func live(apiClient: APIClient) -> Self {
        Self { limit, page in
            let (data, _) = try await apiClient.data(for: BreedsEndpoint.breeds(limit: limit, page: page))
            let response = try JSONDecoder().decode([BreedResponse].self, from: data)

            let imageURLsByID = try await withThrowingTaskGroup(
                of: (String, String).self,
                returning: [String: String].self
            ) { group in
                for breed in response {
                    guard breed.image == nil, let referenceImageID = breed.referenceImageID else {
                        continue
                    }
                    group.addTask {
                        let (data, _) = try await apiClient.data(
                            for: BreedsEndpoint.image(id: referenceImageID)
                        )
                        let imageResponse = try JSONDecoder().decode(
                            ImageResponse.self,
                            from: data
                        )
                        return (breed.id, imageResponse.url)
                    }
                }
                var result: [String: String] = [:]
                for try await (id, url) in group {
                    result[id] = url
                }
                return result
            }

            return response.map { $0.breed(imageURL: $0.image?.url ?? imageURLsByID[$0.id] ?? "") }
        }
    }
}

extension BreedsService: TestDependencyKey {
    public static var previewValue: Self {
        Self(fetchBreeds: { _, _ in Breed.mock })
    }

    public static var testValue: Self {
        Self(fetchBreeds: { _, _ in [] })
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
    let image: BreedImage?
    let referenceImageID: String?
    let temperament: String?

    struct BreedImage: Decodable, Sendable {
        let url: String
    }

    enum CodingKeys: String, CodingKey {
        case description
        case id
        case image
        case lifeSpan = "life_span"
        case name
        case origin
        case referenceImageID = "reference_image_id"
        case temperament
    }

    func breed(imageURL: String) -> Breed {
        let parsedLifeSpan = Breed.parseLifeSpan(self.lifeSpan ?? "")
        return Breed(
            description: self.description ?? "",
            id: self.id,
            imageURL: imageURL,
            isFavorite: false,
            lifeSpanLowerBound: parsedLifeSpan.lower,
            lifeSpanUpperBound: parsedLifeSpan.upper,
            name: self.name,
            origin: self.origin ?? "",
            temperament: self.temperament ?? ""
        )
    }
}

private struct ImageResponse: Decodable, Sendable {
    let url: String
}
