import Dependencies

/// Dependency client for breed caching operations.
public struct BreedsCacheClient: Sendable {
    /// Loads cached breeds.
    public var fetchBreeds: @Sendable () async throws -> [Breed]
    /// Saves breeds into the cache.
    public var saveBreeds: @Sendable (_ breeds: [Breed]) async throws -> Void
    /// Updates the favorite flag for a cached breed.
    public var updateFavoriteBreed: @Sendable (_ breedID: String, _ isFavorite: Bool) async throws -> Void

    /// Creates a cache client from async operations.
    public init(
        fetchBreeds: @escaping @Sendable () async throws -> [Breed],
        saveBreeds: @escaping @Sendable (_ breeds: [Breed]) async throws -> Void,
        updateFavoriteBreed: @escaping @Sendable (_ breedID: String, _ isFavorite: Bool) async throws -> Void
    ) {
        self.fetchBreeds = fetchBreeds
        self.saveBreeds = saveBreeds
        self.updateFavoriteBreed = updateFavoriteBreed
    }
}
