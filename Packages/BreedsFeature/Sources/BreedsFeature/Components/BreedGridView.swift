import AppUI
import Foundation
import PersistenceKit
import SwiftUI

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
