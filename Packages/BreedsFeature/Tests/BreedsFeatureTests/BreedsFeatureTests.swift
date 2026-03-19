import BreedDetails
import ComposableArchitecture
import CustomDump
import DependenciesTestSupport
import Foundation
import NetworkKit
import Testing

@testable import BreedsFeature

@MainActor
struct BreedsFeatureTests {
    @Test
    func onAppearLoadsBreeds() async {
        let store = TestStore(initialState: BreedsFeature.State()) {
            BreedsFeature()
        } withDependencies: {
            $0.breedsService.fetchBreeds = {
                [
                    Breed(
                        description: "Curious and social",
                        id: "abys",
                        imageURL: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg",
                        isFavorite: false,
                        name: "Abyssinian",
                        origin: "Egypt",
                        temperament: "Active"
                    )
                ]
            }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }
        await store.receive(\.breedsResponse.success) {
            $0.breeds = [
                Breed(
                    description: "Curious and social",
                    id: "abys",
                    imageURL: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg",
                    isFavorite: false,
                    name: "Abyssinian",
                    origin: "Egypt",
                    temperament: "Active"
                )
            ]
            $0.hasLoadedBreeds = true
            $0.isLoading = false
        }
    }

    @Test
    func onAppearFailureStopsLoading() async {
        struct TestError: Error {}

        let store = TestStore(initialState: BreedsFeature.State()) {
            BreedsFeature()
        } withDependencies: {
            $0.breedsService.fetchBreeds = {
                throw TestError()
            }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }
        await store.receive(\.breedsResponse.failure) {
            $0.isLoading = false
        }
    }
}
