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
        NavigationStack {
            TabView(selection: Binding(
                get: { self.store.selectedTab },
                set: { self.store.send(.tabSelected($0)) }
            )) {
                AllBreedsView(store: self.store)
                    .tag(BreedsFeature.Tab.allBreeds)
                    .tabItem {
                        Label("All Breeds", systemImage: "square.grid.2x2")
                    }

                FavoriteBreedsView(store: self.store)
                    .tag(BreedsFeature.Tab.favorites)
                    .tabItem {
                        Label("Favorites", systemImage: "star")
                    }
            }
            .navigationDestination(
                store: self.store.scope(state: \.$breedDetails, action: \.breedDetails)
            ) { store in
                BreedDetailsView(store: store)
            }
        }
        .onAppear {
            self.store.send(.onAppear)
        }
    }
}

struct AllBreedsView: View {
    let store: StoreOf<BreedsFeature>

    var body: some View {
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
                    breeds: self.store.breeds,
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

struct BreedGridView: View {
    let breeds: [Breed]
    let breedButtonTapped: (String) -> Void
    let favoriteButtonTapped: (String) -> Void

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 12, alignment: .top),
        count: 3
    )

    var body: some View {
        ScrollView {
            LazyVGrid(columns: self.columns, spacing: 16) {
                ForEach(self.breeds) { breed in
                    BreedCell(
                        breed: breed,
                        breedButtonTapped: { self.breedButtonTapped(breed.id) },
                        favoriteButtonTapped: { self.favoriteButtonTapped(breed.id) }
                    )
                }
            }
            .padding(.horizontal, AppTheme.Layout.screenPadding)
            .padding(.vertical, 20)
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
