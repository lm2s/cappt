import ComposableArchitecture
import AppUI
import SwiftUI

struct FavoriteBreedsView: View {
    let store: StoreOf<BreedsFeature>
    var namespace: Namespace.ID

    var body: some View {
        let favorites = self.store.breeds.filter(\.isFavorite)
        Group {
            if favorites.isEmpty {
                ContentUnavailableView {
                    Label("No Favorites Yet", systemImage: "star")
                } description: {
                    Text("Tap the star on any breed to save it here.")
                }
            } else {
                BreedGridView(
                    breeds: favorites,
                    namespace: self.namespace,
                    breedButtonTapped: { self.store.send(.breedButtonTapped(id: $0)) },
                    favoriteButtonTapped: { self.store.send(.favoriteButtonTapped(id: $0)) }
                )
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.large)
    }
}
