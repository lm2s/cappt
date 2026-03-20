import ComposableArchitecture
import AppUI
import SwiftUI

struct SearchBreedsView: View {
    let store: StoreOf<BreedsFeature>

    var body: some View {
        Group {
            if self.store.filteredBreeds.isEmpty && !self.store.searchText.isEmpty {
                ContentUnavailableView.search(text: self.store.searchText)
            } else {
                BreedGridView(
                    breeds: self.store.filteredBreeds,
                    breedButtonTapped: { self.store.send(.breedButtonTapped(id: $0)) },
                    favoriteButtonTapped: { self.store.send(.favoriteButtonTapped(id: $0)) }
                )
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
    }
}
