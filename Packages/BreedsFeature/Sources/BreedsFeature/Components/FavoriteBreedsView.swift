import ComposableArchitecture
import AppUI
import PersistenceKit
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
                VStack(spacing: 0) {
                    if let average = self.averageLifeSpan(of: favorites) {
                        Text("Average Lifespan: \(average, specifier: "%.0f") years")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                    BreedGridView(
                        breeds: favorites,
                        namespace: self.namespace,
                        breedButtonTapped: { self.store.send(.breedButtonTapped(id: $0)) },
                        favoriteButtonTapped: { self.store.send(.favoriteButtonTapped(id: $0)) }
                    )
                }
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.large)
    }

    private func averageLifeSpan(of breeds: [Breed]) -> Double? {
        let upperBounds = breeds.compactMap(\.lifeSpanUpperBound)
        guard !upperBounds.isEmpty else { return nil }
        return Double(upperBounds.reduce(0, +)) / Double(upperBounds.count)
    }
}
