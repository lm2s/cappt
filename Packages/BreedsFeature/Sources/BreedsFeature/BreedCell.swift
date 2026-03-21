import AppUI
import Foundation
import PersistenceKit
import SwiftUI

struct BreedCell: View {
    let breed: Breed
    var namespace: Namespace.ID
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
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
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
            .accessibilityLabel(Text(self.breed.isFavorite ? "accessibility.favorites.remove" : "accessibility.favorites.add", bundle: .module))
            .accessibilityIdentifier("favorite-button-\(self.breed.id)")
            .padding(8)
        }
        .matchedTransitionSource(id: self.breed.id, in: self.namespace)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("breed-cell-\(self.breed.id)")
    }
}
