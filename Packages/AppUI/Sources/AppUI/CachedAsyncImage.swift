import SwiftUI
import UIKit

public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    let imageFetcher: @Sendable (URL) async throws -> UIImage
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    public init(
        url: URL?,
        imageFetcher: @escaping @Sendable (URL) async throws -> UIImage,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.imageFetcher = imageFetcher
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            if let uiImage {
                self.content(Image(uiImage: uiImage))
            } else {
                self.placeholder()
            }
        }
        .task(id: self.url) {
            guard let url else { return }
            self.uiImage = try? await self.imageFetcher(url)
        }
    }
}
