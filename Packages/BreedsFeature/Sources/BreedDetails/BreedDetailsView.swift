import ComposableArchitecture
import AppUI
import PersistenceKit
import SwiftUI

public struct BreedDetailsView: View {
    let store: StoreOf<BreedDetails>
    
    public init(store: StoreOf<BreedDetails>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .top, spacing: 16) {
                    Text(self.store.breed.name)
                        .font(.largeTitle.weight(.bold))
                        .fontDesign(.serif)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button {
                        self.store.send(.favoriteButtonTapped)
                    } label: {
                        Image(systemName: self.store.breed.isFavorite ? "star.fill" : "star")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(self.store.breed.isFavorite ? AppTheme.Colors.accent : AppTheme.Colors.secondaryText)
                            .frame(width: 44, height: 44)
                            .background(AppTheme.Colors.panelBackground, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(self.store.breed.isFavorite ? "accessibility.favorites.remove" : "accessibility.favorites.add", bundle: .module))
                }
                
                BreedHeroImage(
                    imageURL: self.store.breed.imageURL,
                    name: self.store.breed.name
                )

                Card { Text(self.store.breed.description) }
                BreedFactsCard(title: String(localized: "details.origin", bundle: .module), value: self.store.breed.origin)
                BreedFactsCard(title: String(localized: "details.temperament", bundle: .module), value: self.store.breed.temperament)
            }
            .padding(.horizontal, AppTheme.Layout.screenPadding)
            .padding(.vertical, 20)
        }
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct BreedHeroImage: View {
    let imageURL: String
    let name: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: AppTheme.Layout.cardCornerRadius,
                style: .continuous
            )
            .fill(AppTheme.Colors.panelBackground)
            
            CachedAsyncImage(url: URL(string: self.imageURL)) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                VStack(spacing: 12) {
                    Image(systemName: "photo")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    Text(self.name)
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: AppTheme.Layout.cardCornerRadius,
                style: .continuous
            )
        )
    }
}

private struct BreedFactsCard: View {
    let title: String
    let value: String
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 8) {
                Text(self.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(self.value)
                    .font(.body)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
    }
}

#Preview {
    NavigationStack {
        BreedDetailsView(
            store: Store(
                initialState: BreedDetails.State(breed: Breed.mock[0])
            ) {
                BreedDetails()
            }
        )
    }
}
