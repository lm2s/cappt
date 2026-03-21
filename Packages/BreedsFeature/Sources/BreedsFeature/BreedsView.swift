import BreedDetails
import ComposableArchitecture
import AppUI
import PersistenceKit
import SwiftUI

public struct BreedsView: View {
    @Bindable var store: StoreOf<BreedsFeature>
    @Namespace private var namespace

    public init(store: StoreOf<BreedsFeature>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: Binding(
            get: { self.store.selectedTab },
            set: { self.store.send(.tabSelected($0)) }
        )) {
            Tab(String(localized: "tab.breeds", bundle: .module), systemImage: "square.grid.2x2", value: BreedsFeature.Tab.allBreeds) {
                NavigationStack {
                    AllBreedsView(store: self.store, namespace: self.namespace)
                }
            }

            Tab(String(localized: "tab.favorites", bundle: .module), systemImage: "star", value: BreedsFeature.Tab.favorites) {
                NavigationStack {
                    FavoriteBreedsView(store: self.store, namespace: self.namespace)
                }
            }

            if #available(iOS 26.0, *) {
                Tab(value: BreedsFeature.Tab.search, role: .search) {
                    NavigationStack {
                        SearchBreedsView(store: self.store, namespace: self.namespace)
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
        .sheet(
            item: self.$store.scope(state: \.breedDetails, action: \.breedDetails)
        ) { store in
            NavigationStack {
                BreedDetailsView(store: store)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button {
                                self.store.send(.breedDetails(.dismiss))
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
            }
            .navigationTransition(.zoom(sourceID: store.breed.id, in: self.namespace))
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
