import BreedDetails
import ComposableArchitecture
import AppUI
import NetworkKit
import PersistenceKit
import SwiftUI

public struct BreedsListView: View {
    @Bindable var store: StoreOf<BreedsList>
    @Dependency(\.imageCacheClient) private var imageCacheClient
    @Namespace private var namespace

    public init(store: StoreOf<BreedsList>) {
        self.store = store
    }

    public var body: some View {
        TabView(selection: Binding(
            get: { self.store.selectedTab },
            set: { self.store.send(.tabSelected($0)) }
        )) {
            Tab(String(localized: "tab.breeds", bundle: .module), systemImage: "square.grid.2x2", value: BreedsList.Tab.allBreeds) {
                NavigationStack {
                    AllBreedsView(store: self.store, namespace: self.namespace, imageFetcher: self.imageCacheClient.image)
                }
            }

            Tab(String(localized: "tab.favorites", bundle: .module), systemImage: "star", value: BreedsList.Tab.favorites) {
                NavigationStack {
                    FavoriteBreedsView(store: self.store, namespace: self.namespace, imageFetcher: self.imageCacheClient.image)
                }
            }

            if #available(iOS 26.0, *) {
                Tab(value: BreedsList.Tab.search, role: .search) {
                    NavigationStack {
                        SearchBreedsView(store: self.store, namespace: self.namespace, imageFetcher: self.imageCacheClient.image)
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
                                Image(systemName: "xmark")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                    .accessibilityIdentifier("dismiss-detail-button")
                            }
                            .accessibilityLabel(Text("accessibility.details.close", bundle: .module))
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
    BreedsListView(
        store: Store(initialState: BreedsList.State()) {
            BreedsList()
        }
    )
}
