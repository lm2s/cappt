import AppUI
import ComposableArchitecture
import Foundation
import PersistenceKit
import SwiftUI

struct AllBreedsView: View {
    let store: StoreOf<BreedsFeature>
    var namespace: Namespace.ID

    var body: some View {
        if #available(iOS 26, *) {
            allBreedsView
        } else {
            allBreedsView
                .searchable(
                    text: Binding(
                        get: { self.store.searchText },
                        set: { self.store.send(.searchTextChanged($0)) }
                    )
                )
        }
    }

    @ViewBuilder
    private var allBreedsView: some View {
        Group {
            if self.store.hasError {
                ContentUnavailableView {
                    Label("Unable to Load Breeds", systemImage: "wifi.exclamationmark")
                } description: {
                    Text("Check your connection and try again.")
                } actions: {
                    Button("Retry") {
                        self.store.send(.retryButtonTapped)
                    }
                    .buttonStyle(.bordered)
                }
            } else if self.store.isLoading && self.store.breeds.isEmpty {
                ProgressView("Loading breeds…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                BreedGridView(
                    breeds: self.store.filteredBreeds,
                    namespace: self.namespace,
                    breedButtonTapped: { self.store.send(.breedButtonTapped(id: $0)) },
                    favoriteButtonTapped: { self.store.send(.favoriteButtonTapped(id: $0)) }
                )
            }
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationTitle("Breeds")
        .navigationBarTitleDisplayMode(.large)
    }
}
