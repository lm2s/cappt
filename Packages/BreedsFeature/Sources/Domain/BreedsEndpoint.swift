import Foundation
import NetworkKit

public enum BreedsEndpoint: EndpointType {
    case breeds(limit: Int? = nil, page: Int? = nil)

    public var path: String { "breeds" }

    public var queryItems: [URLQueryItem] {
        switch self {
        case let .breeds(limit, page):
            return [
                URLQueryItem(name: "limit", value: limit.map(String.init)),
                URLQueryItem(name: "page", value: page.map(String.init)),
            ]
            .compactMap { item in
                guard item.value != nil else { return nil }
                return item
            }
        }
    }
}
