//
//  MoviesDatasourceRepo.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

/// Protocol defining the interface for movie data source operations
protocol MoviesDatasourceRepo: AnyObject {
    /// Fetches the initial set of movie data
    /// - Returns: Tuple containing array of movie UI models and hasMoreData flag
    /// - Throws: Network or parsing errors
    func fetchData() async throws -> ([MoviesUIModel], Bool)
    
    /// Searches for movies based on the current keyword
    /// Uses internal keyword state set via update(keyword:)
    /// - Returns: Tuple containing array of filtered movie UI models and hasMoreData flag
    /// - Throws: Network or parsing errors
    func search() async throws -> ([MoviesUIModel], Bool)
    
    /// Updates the search keyword for filtering movies
    /// Set to nil to clear search and return to regular movie list
    /// - Parameter keyword: Search term to filter movies (nil to clear)
    func update(keyword: String?)
    
    /// Refreshes the current movie data (resets to page 1)
    /// - Returns: Tuple containing array of refreshed movie UI models and hasMoreData flag
    /// - Throws: Network or parsing errors
    func refresh() async throws -> ([MoviesUIModel], Bool)
    
    /// Loads additional movies for pagination
    /// - Returns: Tuple containing array of additional movie UI models and hasMoreData flag
    /// - Throws: Network or parsing errors
    func loadMoreData() async throws -> ([MoviesUIModel], Bool)
    
    /// Current language setting for API requests
    var language: String { get }
}

/// Concrete implementation of movie data source repository
/// Handles pagination, search functionality, and API communication
final class MoviesDatasource: MoviesDatasourceRepo {
    
    // MARK: - Properties
    /// Current page number for pagination tracking
    private(set) var page: Int = 1
    /// Language code for API requests (e.g., "en", "es")
    private(set) var language: String
    /// Current search keyword - nil indicates regular movie list mode
    private(set) var keyword: String?
    /// Flag indicating if all available data has been loaded (no more pages)
    private var completed: Bool = false
    /// Network client wrapper for making typed API requests
    let network: NetworkClientImpl<MoviesNetworkClient>
    
    // MARK: - Initialization
    /// Initializes the data source with a network client
    /// - Parameter network: Network client configured for movie API endpoints
    init(network: NetworkClientImpl<MoviesNetworkClient>) {
        self.network = network
        self.language = "en" // Default to English
    }
}

// MARK: - Public API Methods
extension MoviesDatasource {
    /// Fetches the first page of movie data, resetting pagination state
    /// This method resets internal state and loads fresh data from page 1
    func fetchData() async throws -> ([MoviesUIModel], Bool) {
        self.page = 1
        let setup = createNetworkSetup(for: page)
        let data = try await network.fetch(setup: setup)
        self.page = data.page ?? 1
        self.completed = !data.hasMoreData
        let uiModels: [MoviesUIModel] = data.results.map({.init(with: $0)})
        return (uiModels, data.hasMoreData)
    }
    
    /// Loads the next page of movie data for infinite scrolling
    /// Returns empty array with false flag if all data has been loaded
    func loadMoreData() async throws -> ([MoviesUIModel], Bool){
        guard !completed else { return ([], false) }
        let setup = createNetworkSetup(for: page + 1)
        let data = try await network.fetch(setup: setup)
        self.page = data.page ?? self.page
        self.completed = !data.hasMoreData
        let uiModels: [MoviesUIModel] = data.results.map({.init(with: $0)})
        return (uiModels, data.hasMoreData)
    }
    
    /// Refreshes the movie list by resetting all pagination state
    /// Useful for pull-to-refresh functionality
    func refresh() async throws -> ([MoviesUIModel], Bool) {
        self.page = 1
        self.completed = false
        return try await fetchData()
    }
    
    /// Updates the search keyword for filtering movies
    /// Call search() after updating to fetch filtered results
    /// - Parameter keyword: Search term (nil to clear search mode)
    func update(keyword: String?) {
        self.keyword = keyword
    }
    
    /// Performs search using the currently set keyword
    /// Uses fetchData() internally, which respects the current keyword state
    /// - Returns: Tuple containing filtered movie results and pagination info
    /// - Throws: Network or parsing errors
    func search() async throws -> ([MoviesUIModel], Bool){
        return try await fetchData()
    }
}

// MARK: - Private Network Configuration Methods
private extension MoviesDatasource {
    /// Creates appropriate network setup based on current operation mode
    /// Determines whether to use search or discover endpoints based on keyword state
    /// - Parameter page: Target page number for the request
    /// - Returns: Fully configured NetworkSetup ready for execution
    func createNetworkSetup(for page: Int = 1) -> NetworkSetup {
        if let keyword, keyword.count > 2 { // Search mode - use search endpoint
            return createSearchNetworkSetup(for: page, keyword: keyword)
        } else { // Discovery mode - use discover endpoint with sorting
            var params = createDefaultParams(for: page)
            params.updateValue("popularity.desc", forKey: "sort_by")
            params.updateValue("false", forKey: "include_video")
            
            let headers = createHeader()
            return .init(route: API.Routes.movieList, params: params, method: .get, headers: headers)
        }
    }
    
    /// Creates network setup specifically optimized for search operations
    /// - Parameters:
    ///   - page: Target page number for pagination
    ///   - keyword: User's search query string
    /// - Returns: NetworkSetup configured for search API endpoint
    func createSearchNetworkSetup(for page: Int, keyword: String) -> NetworkSetup {
        var params = createDefaultParams(for: page)
        params.updateValue(keyword.trimmingCharacters(in: .whitespacesAndNewlines), forKey: "query")
        let headers = createHeader()
        return .init(route: API.Routes.search, params: params, method: .get, headers: headers)
    }
    
    /// Generates standard query parameters shared across all movie API requests
    /// - Parameter page: Page number for pagination support
    /// - Returns: Dictionary of common API parameters
    func createDefaultParams(for page: Int) -> [String: String] {
        return [
            "include_adult": "false",      // Exclude adult content
            "include_video": "false",      // Exclude video content
            "language": language,          // Localization preference
            "page": "\(page)",            // Pagination control
          ]
    }
    
    /// Constructs authentication headers required for TMDB API access
    /// - Returns: Dictionary containing Bearer token authorization
    private func createHeader() -> [String: String] {
        return ["authorization": "Bearer \(API.token)"]
    }
}
