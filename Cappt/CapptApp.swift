import BreedsFeature
import ComposableArchitecture
import PersistenceKit
import SwiftUI

@main
struct CapptApp: App {
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.environment["UITesting"] == "true" {
                AppView(
                    store: Store(initialState: AppFeature.State()) {
                        AppFeature()
                    } withDependencies: {
                        $0.breedsService = .init(
                            fetchBreeds: { Breed.mock.map { breed in
                                var breed = breed
                                breed.isFavorite = false
                                return breed
                            }}
                        )
                        $0.breedsCacheClient = .init(
                            fetchBreeds: { [] },
                            saveBreeds: { _ in },
                            updateFavoriteBreed: { _, _ in }
                        )
                    }
                )
            } else {
                AppView(
                    store: Store(initialState: AppFeature.State()) {
                        AppFeature()
                    }
                )
            }
        }
    }
}
