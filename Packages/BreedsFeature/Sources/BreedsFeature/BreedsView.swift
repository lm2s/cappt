import BreedDetails
import ComposableArchitecture
import DesignKit
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

private struct BreedCell: View {
    let breed: Breed
    let breedButtonTapped: () -> Void
    let favoriteButtonTapped: () -> Void
    
    var body: some View { // TODO: text over image with blur/glass effect
        ZStack(alignment: .topTrailing) {
            Button(action: self.breedButtonTapped) {
                VStack(spacing: 10) {
                    CachedAsyncImage(url: URL(string: self.breed.imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "photo")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                    .frame(minHeight: 0)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: AppTheme.Layout.cardCornerRadius - 6,
                            style: .continuous
                        )
                    )
                    .background(
                        RoundedRectangle(
                            cornerRadius: AppTheme.Layout.cardCornerRadius - 6,
                            style: .continuous
                        )
                        .fill(AppTheme.Colors.panelBackground)
                    )
                    
                    Text(self.breed.name)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Button(action: self.favoriteButtonTapped) {
                Image(systemName: self.breed.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(self.breed.isFavorite ? AppTheme.Colors.accent : AppTheme.Colors.secondaryText)
                    .padding(8)
                    .background(.regularMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(self.breed.isFavorite ? "Remove from favorites" : "Add to favorites") // TODO: localize
            .padding(8)
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
