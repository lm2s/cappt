import BreedDetails
import ComposableArchitecture
import CustomDump
import DependenciesTestSupport
import Foundation
import PersistenceKit
import Testing

@testable import BreedsFeature

@MainActor
struct BreedsListTests {
    @Test
    func onAppearLoadsBreedsWithCachedFavorites() async {
        var initialState = BreedsList.State()
        initialState.breeds = [Self.abyssinian(isFavorite: false)]

        let store = TestStore(initialState: initialState) {
            BreedsList()
        } withDependencies: {
            $0.breedsService.fetchBreeds = {
                [Self.abyssinian(isFavorite: false)]
            }
            $0.breedsCacheClient.fetchBreeds = {
                [Self.abyssinian(isFavorite: true)]
            }
            $0.breedsCacheClient.saveBreeds = { _ in }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }
        await store.receive(\.breedsResponse.success) {
            $0.breeds = [Self.abyssinian(isFavorite: true)]
            $0.hasLoadedBreeds = true
            $0.isLoading = false
        }
    }

    @Test
    func onAppearFallsBackToCacheOnNetworkFailure() async {
        struct TestError: Error {}

        var initialState = BreedsList.State()
        initialState.breeds = [Self.abyssinian(isFavorite: false)]

        let store = TestStore(initialState: initialState) {
            BreedsList()
        } withDependencies: {
            $0.breedsService.fetchBreeds = {
                throw TestError()
            }
            $0.breedsCacheClient.fetchBreeds = {
                [Self.abyssinian(isFavorite: true)]
            }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }
        await store.receive(\.breedsResponse.success) {
            $0.breeds = [Self.abyssinian(isFavorite: true)]
            $0.hasLoadedBreeds = true
            $0.isLoading = false
        }
    }

    @Test
    func onAppearFailureWithEmptyCacheStopsLoading() async {
        struct TestError: Error {}

        let store = TestStore(initialState: BreedsList.State()) {
            BreedsList()
        } withDependencies: {
            $0.breedsService.fetchBreeds = {
                throw TestError()
            }
            $0.breedsCacheClient.fetchBreeds = { [] }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }
        await store.receive(\.breedsResponse.failure) {
            $0.isLoading = false
            $0.hasError = true
        }
    }

    @Test
    func retryAfterFailureReloadsBreeds() async {
        struct TestError: Error {}
        var shouldFail = true

        let store = TestStore(initialState: BreedsList.State()) {
            BreedsList()
        } withDependencies: {
            $0.breedsService.fetchBreeds = {
                if shouldFail {
                    throw TestError()
                }
                return [Self.abyssinian(isFavorite: false)]
            }
            $0.breedsCacheClient.fetchBreeds = { [] }
            $0.breedsCacheClient.saveBreeds = { _ in }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }
        await store.receive(\.breedsResponse.failure) {
            $0.isLoading = false
            $0.hasError = true
        }

        shouldFail = false

        await store.send(.retryButtonTapped) {
            $0.hasError = false
            $0.hasLoadedBreeds = false
        }
        await store.receive(\.onAppear) {
            $0.isLoading = true
        }
        await store.receive(\.breedsResponse.success) {
            $0.breeds = [Self.abyssinian(isFavorite: false)]
            $0.hasLoadedBreeds = true
            $0.isLoading = false
        }
    }

    @Test
    func favoriteButtonTappedPersistsFavorite() async {
        let recorder = FavoriteBreedsRecorder()

        var initialState = BreedsList.State()
        initialState.breeds = [Self.abyssinian(isFavorite: false)]

        let store = TestStore(initialState: initialState) {
            BreedsList()
        } withDependencies: {
            $0.breedsCacheClient.updateFavoriteBreed = { id, isFavorite in
                await recorder.record(id: id, isFavorite: isFavorite)
            }
        }

        await store.send(.favoriteButtonTapped(id: "abys")) {
            $0.breeds[0].isFavorite = true
        }
        await store.finish()
        let updates = await recorder.updates()

        expectNoDifference(
            updates,
            [FavoriteUpdate(id: "abys", isFavorite: true)]
        )
    }

    @Test
    func favoriteButtonTappedFromDetailsPersistsFavorite() async {
        let recorder = FavoriteBreedsRecorder()
        let breed = Self.abyssinian(isFavorite: false)

        var initialState = BreedsList.State()
        initialState.breeds = [breed]
        initialState.breedDetails = BreedDetails.State(breed: breed)

        let store = TestStore(initialState: initialState) {
            BreedsList()
        } withDependencies: {
            $0.breedsCacheClient.updateFavoriteBreed = { id, isFavorite in
                await recorder.record(id: id, isFavorite: isFavorite)
            }
        }

        await store.send(.breedDetails(.presented(.favoriteButtonTapped))) {
            $0.breeds[0].isFavorite = true
            $0.breedDetails?.breed.isFavorite = true
        }
        await store.finish()
        let updates = await recorder.updates()

        expectNoDifference(
            updates,
            [FavoriteUpdate(id: "abys", isFavorite: true)]
        )
    }

    nonisolated private static func abyssinian(isFavorite: Bool) -> Breed {
        Breed(
            description: "Curious and social",
            id: "abys",
            imageURL: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg",
            isFavorite: isFavorite,
            lifeSpanLowerBound: 14,
            lifeSpanUpperBound: 15,
            name: "Abyssinian",
            origin: "Egypt",
            temperament: "Active"
        )
    }
}

private struct FavoriteUpdate: Equatable, Sendable {
    let id: String
    let isFavorite: Bool
}

private actor FavoriteBreedsRecorder {
    private var recordedUpdates: [FavoriteUpdate] = []

    func record(id: String, isFavorite: Bool) {
        self.recordedUpdates.append(
            FavoriteUpdate(id: id, isFavorite: isFavorite)
        )
    }

    func updates() -> [FavoriteUpdate] {
        self.recordedUpdates
    }
}
