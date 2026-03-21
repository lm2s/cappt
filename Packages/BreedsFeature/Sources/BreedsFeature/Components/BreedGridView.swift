import AppUI
import Foundation
import PersistenceKit
import SwiftUI
import UIKit

struct BreedGridView: View {
    let breeds: [Breed]
    var namespace: Namespace.ID
    let imageFetcher: @Sendable (URL) async throws -> UIImage
    let breedButtonTapped: (String) -> Void
    let favoriteButtonTapped: (String) -> Void
    var isLoadingMore: Bool = false
    var onLoadMore: (() -> Void)? = nil

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
                        namespace: self.namespace,
                        imageFetcher: self.imageFetcher,
                        breedButtonTapped: { self.breedButtonTapped(breed.id) },
                        favoriteButtonTapped: { self.favoriteButtonTapped(breed.id) }
                    )
                }
            }
            .padding(.horizontal, AppTheme.Layout.screenPadding)
            .padding(.vertical, 20)

            if self.isLoadingMore {
                ProgressView()
                    .padding()
            } else if self.onLoadMore != nil {
                Color.clear
                    .frame(height: 1)
                    .onAppear { self.onLoadMore?() }
            }
        }
    }
}
