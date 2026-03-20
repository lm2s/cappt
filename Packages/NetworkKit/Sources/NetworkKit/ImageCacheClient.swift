import Dependencies
import Foundation
import UIKit

public struct ImageCacheClient: Sendable {
    public var image: @Sendable (_ url: URL) async throws -> UIImage

    public init(image: @escaping @Sendable (_ url: URL) async throws -> UIImage) {
        self.image = image
    }
}

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
    var imageCacheClient: ImageCacheClient {
        get { self[ImageCacheClient.self] }
        set { self[ImageCacheClient.self] = newValue }
    }
}

private actor ImageCache {
    private let memoryCache = NSCache<NSString, UIImage>()
    private let cacheDirectory: URL

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDirectory = caches.appendingPathComponent("ImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
    }

    func image(for url: URL) async throws -> UIImage {
        let key = url.absoluteString as NSString

        if let cached = self.memoryCache.object(forKey: key) {
            return cached
        }

        let diskPath = self.diskURL(for: url)
        if let data = try? Data(contentsOf: diskPath), let image = UIImage(data: data) {
            self.memoryCache.setObject(image, forKey: key)
            return image
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageCacheError.invalidImageData
        }
        self.memoryCache.setObject(image, forKey: key)
        try? data.write(to: diskPath)
        return image
    }

    private func diskURL(for url: URL) -> URL {
        let filename = url.absoluteString.data(using: .utf8)!.base64EncodedString()
        return self.cacheDirectory.appendingPathComponent(filename)
    }
}

enum ImageCacheError: Error {
    case invalidImageData
}
