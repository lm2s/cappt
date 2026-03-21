import ComposableArchitecture
import AppUI
import PersistenceKit
import SwiftUI

struct FavoriteBreedsView: View {
    let store: StoreOf<BreedsList>
    var namespace: Namespace.ID

    var body: some View {
        let favorites = self.store.breeds.filter(\.isFavorite)
        Group {
            if favorites.isEmpty {
                ContentUnavailableView {
                    Label {
                        Text("favorites.empty.title", bundle: .module)
                    } icon: {
                        Image(systemName: "star")
                    }
                } description: {
                    Text("favorites.empty.message", bundle: .module)
                }
                .accessibilityIdentifier("favorites-empty-state")
            } else {
                VStack(spacing: 0) {
                    if let average = self.averageLifeSpan(of: favorites) {
                        Text(String(localized: "favorites.averageLifespan \(String(format: "%.0f", average))", bundle: .module))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .accessibilityIdentifier("average-lifespan")
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
        .navigationTitle(Text("nav.favorites", bundle: .module))
        .navigationBarTitleDisplayMode(.large)
    }

    private func averageLifeSpan(of breeds: [Breed]) -> Double? {
        let upperBounds = breeds.compactMap(\.lifeSpanUpperBound)
        guard !upperBounds.isEmpty else { return nil }
        return Double(upperBounds.reduce(0, +)) / Double(upperBounds.count)
    }
}
