import Dependencies

public struct FavoriteBreedsClient: Sendable {
    public var fetchFavoriteBreedIDs: @Sendable () async throws -> Set<String>
    public var updateFavoriteBreed: @Sendable (_ breedID: String, _ isFavorite: Bool) async throws -> Void

    public init(
        fetchFavoriteBreedIDs: @escaping @Sendable () async throws -> Set<String>,
        updateFavoriteBreed: @escaping @Sendable (_ breedID: String, _ isFavorite: Bool) async throws -> Void
    ) {
        self.fetchFavoriteBreedIDs = fetchFavoriteBreedIDs
        self.updateFavoriteBreed = updateFavoriteBreed
    }
}

extension FavoriteBreedsClient: TestDependencyKey {
    public static var previewValue: Self {
        Self(
            fetchFavoriteBreedIDs: {
                try await PersistenceController.preview.fetchFavoriteBreedIDs()
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
            fetchFavoriteBreedIDs: { [] },
            updateFavoriteBreed: { _, _ in }
        )
    }
}

extension FavoriteBreedsClient: DependencyKey {
    public static var liveValue: Self {
        Self(
            fetchFavoriteBreedIDs: {
                try await PersistenceController.shared.fetchFavoriteBreedIDs()
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
    var favoriteBreedsClient: FavoriteBreedsClient {
        get { self[FavoriteBreedsClient.self] }
        set { self[FavoriteBreedsClient.self] = newValue }
    }
}
