import ComposableArchitecture
import DesignKit
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
        ScrollView {
            LazyVGrid(columns: self.columns, spacing: 16) {
                ForEach(self.store.breeds) { breed in
                    BreedCell(breed: breed) {
                        self.store.send(.favoriteButtonTapped(id: breed.id))
                    }
                }
            }
            .padding(.horizontal, AppTheme.Layout.screenPadding)
            .padding(.vertical, 20)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .onAppear {
            self.store.send(.onAppear)
        }
    }
}

private struct BreedCell: View {
    let breed: BreedsFeature.State.Breed
    let favoriteButtonTapped: () -> Void
    
    var body: some View { // TODO: text over image with blur/glass effect
        VStack(spacing: 10) {
            RoundedRectangle(
                cornerRadius: AppTheme.Layout.cardCornerRadius - 6,
                style: .continuous
            )
            .fill(AppTheme.Colors.panelBackground)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
            .overlay(alignment: .topTrailing) {
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
            
            Text(self.breed.name)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .lineLimit(2)
                .multilineTextAlignment(.center)
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
