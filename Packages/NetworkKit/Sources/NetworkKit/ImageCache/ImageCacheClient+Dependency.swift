import ComposableArchitecture
import Foundation
import UIKit

extension ImageCacheClient: DependencyKey {
    public static var liveValue: Self {
        let cache = ImageCache()
        return Self(
            image: { url in
                try await cache.image(for: url)
            }
        )
    }
}

extension ImageCacheClient: TestDependencyKey {
    public static var previewValue: Self {
        Self(image: { _ in UIImage() })
    }

    public static var testValue: Self {
        Self(image: { _ in UIImage() })
    }
}

public extension DependencyValues {
    /// Access to the app's image cache client dependency.
    var imageCacheClient: ImageCacheClient {
        get { self[ImageCacheClient.self] }
        set { self[ImageCacheClient.self] = newValue }
    }
}
