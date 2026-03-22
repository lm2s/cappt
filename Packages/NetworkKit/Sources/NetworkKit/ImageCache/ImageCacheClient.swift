import CryptoKit
import Dependencies
import Foundation
import UIKit

/// A dependency client that loads and caches remote images.
public struct ImageCacheClient: Sendable {
    /// Loads an image for a URL, using the configured cache behavior.
    public var image: @Sendable (_ url: URL) async throws -> UIImage

    /// Creates an image cache client.
    public init(image: @escaping @Sendable (_ url: URL) async throws -> UIImage) {
        self.image = image
    }
}
