import Foundation

public struct APIClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await self.session.data(for: request)
    }
    
    public func decode<Response: Decodable>(
        _ type: Response.Type = Response.self,
        for request: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> Response {
        let (data, _) = try await self.data(for: request)
        return try decoder.decode(Response.self, from: data)
    }
}
