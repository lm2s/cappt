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
                    Label {
                        Text("error.title", bundle: .module)
                    } icon: {
                        Image(systemName: "wifi.exclamationmark")
                    }
                } description: {
                    Text("error.message", bundle: .module)
                } actions: {
                    Button {
                        self.store.send(.retryButtonTapped)
                    } label: {
                        Text("error.retry", bundle: .module)
                    }
                    .buttonStyle(.bordered)
                }
            } else if self.store.isLoading && self.store.breeds.isEmpty {
                ProgressView {
                    Text("loading.message", bundle: .module)
                }
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
        .navigationTitle(Text("nav.breeds", bundle: .module))
        .navigationBarTitleDisplayMode(.large)
    }
}
