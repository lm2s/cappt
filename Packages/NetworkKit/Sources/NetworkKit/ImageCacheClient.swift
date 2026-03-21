import CryptoKit
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
    private var inFlight: [URL: Task<UIImage, Error>] = [:]

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

        if let existing = self.inFlight[url] {
            return try await existing.value
        }

        let task = Task<UIImage, Error> { [cacheDirectory] in
            let diskPath = Self.diskURL(for: url, in: cacheDirectory)
            if let image = await Task.detached(priority: .userInitiated, operation: {
                guard let data = try? Data(contentsOf: diskPath) else { return nil as UIImage? }
                return UIImage(data: data)
            }).value {
                return image
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                throw ImageCacheError.invalidImageData
            }
            try? data.write(to: diskPath)
            return image
        }

        self.inFlight[url] = task

        do {
            let image = try await task.value
            self.memoryCache.setObject(image, forKey: key)
            self.inFlight[url] = nil
            return image
        } catch {
            self.inFlight[url] = nil
            throw error
        }
    }

    private static func diskURL(for url: URL, in directory: URL) -> URL {
        let hash = SHA256.hash(data: Data(url.absoluteString.utf8))
        let filename = hash.compactMap { String(format: "%02x", $0) }.joined()
        return directory.appendingPathComponent(filename)
    }
}

enum ImageCacheError: Error {
    case invalidImageData
}
