import BreedDetails
import ComposableArchitecture
import AppUI
import PersistenceKit
import SwiftUI

public struct BreedsView: View {
    let store: StoreOf<BreedsFeature>
    
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 12, alignment: .top),
        count: 3
    )
    
    public init(store: StoreOf<BreedsFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: self.columns, spacing: 16) {
                    ForEach(self.store.breeds) { breed in
                        BreedCell(
                            breed: breed,
                            breedButtonTapped: {
                                self.store.send(.breedButtonTapped(id: breed.id))
                            },
                            favoriteButtonTapped: {
                                self.store.send(.favoriteButtonTapped(id: breed.id))
                            }
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Layout.screenPadding)
                .padding(.vertical, 20)
            }
            .background(AppTheme.Colors.background.ignoresSafeArea())
            .navigationTitle("Breeds")
            .navigationBarTitleDisplayMode(.large)
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

#Preview {
    BreedsView(
        store: Store(initialState: BreedsFeature.State()) {
            BreedsFeature()
        }
    )
}
