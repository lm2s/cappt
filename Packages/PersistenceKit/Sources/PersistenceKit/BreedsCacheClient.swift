import Dependencies

public struct BreedsCacheClient: Sendable {
    public var fetchBreeds: @Sendable () async throws -> [Breed]
    public var saveBreeds: @Sendable (_ breeds: [Breed]) async throws -> Void
    public var updateFavoriteBreed: @Sendable (_ breedID: String, _ isFavorite: Bool) async throws -> Void

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

extension BreedsCacheClient: TestDependencyKey {
    public static var previewValue: Self {
        let repo = BreedsRepository(controller: .preview)
        return Self(
            fetchBreeds: { try await repo.fetchBreeds() },
            saveBreeds: { try await repo.saveBreeds($0) },
            updateFavoriteBreed: { try await repo.setFavoriteBreed(id: $0, isFavorite: $1) }
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
        let repo = BreedsRepository(controller: .shared)
        return Self(
            fetchBreeds: { try await repo.fetchBreeds() },
            saveBreeds: { try await repo.saveBreeds($0) },
            updateFavoriteBreed: { try await repo.setFavoriteBreed(id: $0, isFavorite: $1) }
        )
    }
}

public extension DependencyValues {
    var breedsCacheClient: BreedsCacheClient {
        get { self[BreedsCacheClient.self] }
        set { self[BreedsCacheClient.self] = newValue }
    }
}
