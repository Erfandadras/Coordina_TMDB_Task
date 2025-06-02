//
//  MoviesNetworkClient.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

/// Network client for fetching movie data from TMDB API
class MoviesNetworkClient: NetworkClient {
    /// Associated type defining the expected response model
    typealias T = GenericPaginateRM<MovieRM>
    
    /// Fetches paginated movie data from the network
    /// - Parameter setup: Network configuration for the request
    /// - Returns: Generic paginated response containing movie data
    /// - Throws: Network or parsing errors
    func fetch(setup: NetworkSetup) async throws -> GenericPaginateRM<MovieRM> {
        try await NetworkService.fetch(parser: self, setup: setup)
    }
}

// MARK: - Mock Implementation
/// Mock network client for testing and development purposes
/// Returns data from local JSON file instead of making network requests
final class MockMoviesNetworkClient: MoviesNetworkClient {
    
    /// Mock implementation that loads data from bundled JSON file
    /// - Parameter setup: Network configuration (used for filtering mock data)
    /// - Returns: Mock movie data with optional filtering applied
    /// - Throws: Decoding errors if JSON file is malformed
    override func fetch(setup: NetworkSetup) async throws -> GenericPaginateRM<MovieRM> {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                // Load mock data from bundled JSON file
                var result: GenericPaginateRM<MovieRM> = try Bundle.main.decode("Movies")
                var data = result.results
                if let query = setup.params?["query"] {
                   data = data.filter({$0.filter(with: query)})
                }
                result.results = data
                
                // Simulate network delay for realistic testing
                delayWithSeconds(0.2) {
                    continuation.resume(returning: result)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
