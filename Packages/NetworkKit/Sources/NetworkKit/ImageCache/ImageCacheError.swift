import Foundation

/// Errors thrown while loading cached images.
enum ImageCacheError: Error {
    /// The downloaded data could not be decoded into an image.
    case invalidImageData
}
