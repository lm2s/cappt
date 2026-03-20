import Foundation

public struct CachedBreed: Equatable, Sendable {
    public let breedDescription: String
    public let id: String
    public let imageURL: String
    public var isFavorite: Bool
    public let name: String
    public let origin: String
    public let temperament: String

    public init(
        breedDescription: String,
        id: String,
        imageURL: String,
        isFavorite: Bool,
        name: String,
        origin: String,
        temperament: String
    ) {
        self.breedDescription = breedDescription
        self.id = id
        self.imageURL = imageURL
        self.isFavorite = isFavorite
        self.name = name
        self.origin = origin
        self.temperament = temperament
    }
}
