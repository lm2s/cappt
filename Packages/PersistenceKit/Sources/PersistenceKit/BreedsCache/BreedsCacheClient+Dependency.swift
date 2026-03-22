import Dependencies

extension BreedsCacheClient: TestDependencyKey {
    /// A preview-friendly cache client backed by the in-memory store.
    public static var previewValue: Self {
        let repo = BreedsRepository(controller: .preview)
        return Self(
            fetchBreeds: { try await repo.fetchBreeds() },
            saveBreeds: { try await repo.saveBreeds($0) },
            updateFavoriteBreed: { try await repo.setFavoriteBreed(id: $0, isFavorite: $1) }
        )
    }

    /// A no-op cache client for tests.
    public static var testValue: Self {
        Self(
            fetchBreeds: { [] },
            saveBreeds: { _ in },
            updateFavoriteBreed: { _, _ in }
        )
    }
}

extension BreedsCacheClient: DependencyKey {
    /// The live cache client backed by the shared store.
    public static var liveValue: Self {
        let repo = BreedsRepository(controller: .shared)
        return Self(
            fetchBreeds: { try await repo.fetchBreeds() },
            saveBreeds: { try await repo.saveBreeds($0) },
            updateFavoriteBreed: { try await repo.setFavoriteBreed(id: $0, isFavorite: $1) }
        )
    }
}

public extension DependencyValues {
    /// Access to the breed cache dependency.
    var breedsCacheClient: BreedsCacheClient {
        get { self[BreedsCacheClient.self] }
        set { self[BreedsCacheClient.self] = newValue }
    }
}
