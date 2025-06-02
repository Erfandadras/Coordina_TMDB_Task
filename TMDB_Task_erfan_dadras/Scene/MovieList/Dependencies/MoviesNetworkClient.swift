import Foundation

class MoviesNetworkClient: NetworkClient {
    typealias T = PaginateMoviesResponseModel // associated type
    
    func fetch(setup: NetworkSetup) async throws -> PaginateMoviesResponseModel {
        try await NetworkService.fetch(parser: self, setup: setup)
    }
}

// MARK: - mock CreditCardsNetworkClient
final class MockMoviesNetworkClient: MoviesNetworkClient {
    override func fetch(setup: NetworkSetup) async throws -> PaginateMoviesResponseModel {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                var result: PaginateMoviesResponseModel = try Bundle.main.decode("Movies")
                var data = result.results
                if let query = setup.params?["query"] {
                   data = data.filter({$0.filter(with: query)})
                }
                result.results = data
                delayWithSeconds(0.2) { // simulate request
                    continuation.resume(returning: result)
                }
            } catch {
                continuation.resume(throwing: error)
            }

        }
    }
}
