import BreedDetails
import ComposableArchitecture
import AppUI
import PersistenceKit
import SwiftUI

public struct BreedsView: View {
    let store: StoreOf<BreedsFeature>

    public init(store: StoreOf<BreedsFeature>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: Binding(
            get: { self.store.selectedTab },
            set: { self.store.send(.tabSelected($0)) }
        )) {
            Tab("Breeds", systemImage: "square.grid.2x2", value: BreedsFeature.Tab.allBreeds) {
                NavigationStack {
                    AllBreedsView(store: self.store)
                        .navigationDestination(
                            store: self.store.scope(state: \.$breedDetails, action: \.breedDetails)
                        ) { store in
                            BreedDetailsView(store: store)
                        }
                }
            }

            Tab("Favorites", systemImage: "star", value: BreedsFeature.Tab.favorites) {
                NavigationStack {
                    FavoriteBreedsView(store: self.store)
                }
            }

            if #available(iOS 26.0, *) {
                Tab(value: BreedsFeature.Tab.search, role: .search) {
                    NavigationStack {
                        SearchBreedsView(store: self.store)
                            .navigationDestination(
                                store: self.store.scope(state: \.$breedDetails, action: \.breedDetails)
                            ) { store in
                                BreedDetailsView(store: store)
                            }
                    }
                    .searchable(
                        text: Binding(
                            get: { self.store.searchText },
                            set: { self.store.send(.searchTextChanged($0)) }
                        )
                    )
                }
            }
        }
        .onAppear {
            self.store.send(.onAppear)
        }
    }
}

#Preview {
    BreedsView(
        store: Store(initialState: BreedsFeature.State()) {
            BreedsFeature()
        }
    )
}
