import Dependencies
import NetworkKit
import SwiftUI

public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @Dependency(\.imageCacheClient) private var imageCacheClient
    @State private var uiImage: UIImage?

    public init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
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
            self.uiImage = try? await self.imageCacheClient.image(url)
        }
    }
}
