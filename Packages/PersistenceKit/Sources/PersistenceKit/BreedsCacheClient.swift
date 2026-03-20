import Dependencies

public struct BreedsCacheClient: Sendable {
    public var fetchBreeds: @Sendable () async throws -> [CachedBreed]
    public var saveBreeds: @Sendable (_ breeds: [CachedBreed]) async throws -> Void
    public var updateFavoriteBreed: @Sendable (_ breedID: String, _ isFavorite: Bool) async throws -> Void

    public init(
        fetchBreeds: @escaping @Sendable () async throws -> [CachedBreed],
        saveBreeds: @escaping @Sendable (_ breeds: [CachedBreed]) async throws -> Void,
        updateFavoriteBreed: @escaping @Sendable (_ breedID: String, _ isFavorite: Bool) async throws -> Void
    ) {
        self.fetchBreeds = fetchBreeds
        self.saveBreeds = saveBreeds
        self.updateFavoriteBreed = updateFavoriteBreed
    }
}

extension BreedsCacheClient: TestDependencyKey {
    public static var previewValue: Self {
        Self(
            fetchBreeds: {
                try await PersistenceController.preview.fetchBreeds()
            },
            saveBreeds: { breeds in
                try await PersistenceController.preview.saveBreeds(breeds)
            },
            updateFavoriteBreed: { breedID, isFavorite in
                try await PersistenceController.preview.setFavoriteBreed(
                    id: breedID,
                    isFavorite: isFavorite
                )
            }
        )
    }

    public static var testValue: Self {
        Self(
            fetchBreeds: { [] },
            saveBreeds: { _ in },
            updateFavoriteBreed: { _, _ in }
        )
    }
}

extension BreedsCacheClient: DependencyKey {
    public static var liveValue: Self {
        Self(
            fetchBreeds: {
                try await PersistenceController.shared.fetchBreeds()
            },
            saveBreeds: { breeds in
                try await PersistenceController.shared.saveBreeds(breeds)
            },
            updateFavoriteBreed: { breedID, isFavorite in
                try await PersistenceController.shared.setFavoriteBreed(
                    id: breedID,
                    isFavorite: isFavorite
                )
            }
        )
    }
}

public extension DependencyValues {
    var breedsCacheClient: BreedsCacheClient {
        get { self[BreedsCacheClient.self] }
        set { self[BreedsCacheClient.self] = newValue }
    }
}
