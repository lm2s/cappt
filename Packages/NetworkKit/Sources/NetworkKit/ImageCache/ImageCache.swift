import CryptoKit
import Dependencies
import Foundation
import UIKit

/// An actor-backed image cache with in-memory and disk storage.
actor ImageCache {
    private let memoryCache = NSCache<NSString, UIImage>()
    private let cacheDirectory: URL
    private var inFlight: [URL: Task<UIImage, Error>] = [:]
    private let maxDiskCacheSize: Int = 50_000_000 // 50 MB

    init() {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        self.cacheDirectory = caches.appendingPathComponent("ImageCache", isDirectory: true)
        try? FileManager.default.createDirectory(at: self.cacheDirectory, withIntermediateDirectories: true)
        observeBackgroundNotification()
    }

    private nonisolated func observeBackgroundNotification() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            guard let self else { return }
            Task.detached(priority: .utility) {
                await self.trimDiskCache()
            }
        }
    }

    private func trimDiskCache() {
        let fm = FileManager.default
        let keys: [URLResourceKey] = [.contentModificationDateKey, .fileSizeKey]
        guard let files = try? fm.contentsOfDirectory(
            at: cacheDirectory, includingPropertiesForKeys: keys
        ) else { return }

        var entries: [(url: URL, date: Date, size: Int)] = []
        var totalSize = 0
        for file in files {
            guard let values = try? file.resourceValues(forKeys: Set(keys)),
                  let size = values.fileSize,
                  let date = values.contentModificationDate else { continue }
            entries.append((file, date, size))
            totalSize += size
        }

        guard totalSize > maxDiskCacheSize else { return }

        entries.sort { $0.date < $1.date }
        for entry in entries {
            guard totalSize > maxDiskCacheSize else { break }
            try? fm.removeItem(at: entry.url)
            totalSize -= entry.size
        }
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
