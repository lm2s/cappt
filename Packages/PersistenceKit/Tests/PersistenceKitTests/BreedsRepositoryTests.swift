import CustomDump
import Testing

import PersistenceKit

@Suite(.serialized)
struct BreedsRepositoryTests {
    @Test
    func saveAndFetchBreedsSortsByNameAndPreservesOptionalLifeSpanBounds() async throws {
        let repository = Self.makeRepository()
        let abyssinian = Self.makeBreed(
            id: "abys",
            name: "Abyssinian",
            isFavorite: false,
            lifeSpanLowerBound: 14,
            lifeSpanUpperBound: 15
        )
        let bengal = Self.makeBreed(
            id: "beng",
            name: "Bengal",
            isFavorite: true,
            lifeSpanLowerBound: nil,
            lifeSpanUpperBound: nil
        )

        try await repository.saveBreeds([bengal, abyssinian])

        let fetchedBreeds = try await repository.fetchBreeds()

        expectNoDifference(
            fetchedBreeds,
            [abyssinian, bengal]
        )
    }

    @Test
    func saveBreedsUpdatesExistingBreedInsteadOfDuplicatingIt() async throws {
        let repository = Self.makeRepository()
        let originalBreed = Self.makeBreed(
            id: "abys",
            name: "Abyssinian",
            isFavorite: false,
            lifeSpanLowerBound: 12,
            lifeSpanUpperBound: 14
        )
        let updatedBreed = Self.makeBreed(
            id: "abys",
            name: "Abyssinian Updated",
            isFavorite: true,
            lifeSpanLowerBound: 13,
            lifeSpanUpperBound: 16
        )

        try await repository.saveBreeds([originalBreed])
        try await repository.saveBreeds([updatedBreed])

        let fetchedBreeds = try await repository.fetchBreeds()

        expectNoDifference(fetchedBreeds, [updatedBreed])
    }

    @Test
    func setFavoriteBreedUpdatesSavedBreed() async throws {
        let repository = Self.makeRepository()
        let breed = Self.makeBreed(
            id: "abys",
            name: "Abyssinian",
            isFavorite: false
        )

        try await repository.saveBreeds([breed])
        try await repository.setFavoriteBreed(id: breed.id, isFavorite: true)

        let fetchedBreeds = try await repository.fetchBreeds()

        expectNoDifference(
            fetchedBreeds,
            [Self.makeBreed(id: "abys", name: "Abyssinian", isFavorite: true)]
        )
    }

    @Test
    func setFavoriteBreedDoesNothingWhenBreedIsMissing() async throws {
        let repository = Self.makeRepository()
        let breed = Self.makeBreed(
            id: "abys",
            name: "Abyssinian",
            isFavorite: false
        )

        try await repository.saveBreeds([breed])
        try await repository.setFavoriteBreed(id: "missing", isFavorite: true)

        let fetchedBreeds = try await repository.fetchBreeds()

        expectNoDifference(fetchedBreeds, [breed])
    }
}

private extension BreedsRepositoryTests {
    static func makeRepository() -> BreedsRepository {
        BreedsRepository(controller: PersistenceController(inMemory: true))
    }

    static func makeBreed(
        id: String,
        name: String,
        isFavorite: Bool,
        lifeSpanLowerBound: Int? = nil,
        lifeSpanUpperBound: Int? = nil
    ) -> Breed {
        Breed(
            description: "\(name) description",
            id: id,
            imageURL: "https://example.com/\(id).jpg",
            isFavorite: isFavorite,
            lifeSpanLowerBound: lifeSpanLowerBound,
            lifeSpanUpperBound: lifeSpanUpperBound,
            name: name,
            origin: "Origin",
            temperament: "Curious"
        )
    }
}
