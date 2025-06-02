//
//  TMDB_Task_erfan_dadrasTests.swift
//  TMDB_Task_erfan_dadrasTests
//
//  Created by Erfan mac mini on 6/2/25.
//

import Testing
import Foundation
@testable import TMDB_Task_erfan_dadras


// MARK: - MovieListViewModel Tests
/// Test suite specifically for MovieListViewModel using real MockMoviesNetworkClient and Movies.json data
struct MovieListViewModelTests {
    
    // MARK: - Helper Methods
    /// Creates a MovieListViewModel with MockMoviesNetworkClient for testing
    private func createTestViewModel() -> MovieListViewModel {
        let mockClient = MockMoviesNetworkClient()
        let dataSource = MoviesDatasource(network: .init(client: mockClient))
        return MovieListViewModel(dataSource: dataSource)
    }
    
    // MARK: - Initialization Tests
    @Test("MovieListViewModel initializes with empty state")
    func testInitialization() async throws {
        // Given & When
        let viewModel = createTestViewModel()
        
        // Then
        #expect(viewModel.movies.isEmpty)
        #expect(viewModel.keyword.isEmpty)
        #expect(viewModel.hasMoreData == false)
        #expect(viewModel.state == nil)
    }
    
    // MARK: - Data Fetching Tests
    @Test("fetchData loads movies from Movies.json successfully")
    func testFetchDataSuccess() async throws {
        // Given
        let viewModel = createTestViewModel()
        
        // When
        viewModel.fetchData()
        
        // Wait for async updates to complete
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Then
        #expect(!viewModel.movies.isEmpty, "Movies should be loaded from JSON")
        #expect(viewModel.movies.count == 20, "Should load 20 movies from Movies.json")
        #expect(viewModel.state == .success, "State should be success")
        
        // Verify specific movie data from Movies.json
        let firstMovie = viewModel.movies.first!
        #expect(firstMovie.id == 552524, "First movie should be Lilo & Stitch with ID 552524")
        #expect(firstMovie.title == "Lilo & Stitch", "First movie title should match")
        #expect(firstMovie.voteAverage == 7.113, "Vote average should match JSON data")
    }
    
    @Test("fetchData handles network simulation delay")
    func testFetchDataWithDelay() async throws {
        // Given
        let viewModel = createTestViewModel()
        let startTime = Date()
        
        // When
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 300_000_000)
        
        // Then
        let elapsedTime = Date().timeIntervalSince(startTime)
        #expect(elapsedTime >= 0.2, "Should respect the 0.2 second delay in MockMoviesNetworkClient")
        #expect(!viewModel.movies.isEmpty, "Movies should be loaded after delay")
    }
    
    // MARK: - Search Tests
    @Test("search functionality filters movies based on keyword")
    func testSearchFunctionality() async throws {
        // Given
        let viewModel = createTestViewModel()
        
        // When - search for "Lilo" (appears in Movies.json)
        viewModel.keyword = "Lilo"
        
        // Wait for debounced search to trigger
        try await Task.sleep(nanoseconds: 800_000_000) // 0.6 seconds
        
        // Then
        #expect(!viewModel.movies.isEmpty, "Should find movies matching 'Lilo'")
        #expect(viewModel.movies.count == 2, "Should find 2 Lilo & Stitch movies in JSON")
        
        // Verify all returned movies contain the search term
        for movie in viewModel.movies {
            #expect(movie.title.lowercased().contains("lilo"), "All movies should contain 'lilo' in title")
        }
    }
    
    @Test("search with non-existent keyword returns empty results")
    func testSearchNoResults() async throws {
        // Given
        let viewModel = createTestViewModel()
        
        // When - search for something that doesn't exist
        viewModel.keyword = "NonExistentMovie12345"
        
        // Wait for debounced search
        try await Task.sleep(nanoseconds: 800_000_000)
        
        // Then
        #expect(viewModel.movies.isEmpty, "Should return empty results for non-existent search")
        #expect(viewModel.state == .noData, "State should be noData when no results found")
    }
    
    @Test("clearing search keyword returns to full movie list")
    func testClearSearch() async throws {
        // Given
        let viewModel = createTestViewModel()
        
        // When - first perform a search
        viewModel.keyword = "Captain"
        try await Task.sleep(nanoseconds: 800_000_000)
        let searchResultsCount = viewModel.movies.count
        
        // Then clear the search
        viewModel.keyword = ""
        try await Task.sleep(nanoseconds: 800_000_000)
        
        // Then
        #expect(viewModel.movies.count == 20, "Should return to full list of 20 movies")
        #expect(viewModel.movies.count > searchResultsCount, "Full list should be larger than search results")
        #expect(viewModel.state == .success, "State should be success")
    }
    
    @Test("short search keywords are ignored")
    func testShortKeywordIgnored() async throws {
        // Given
        let viewModel = createTestViewModel()
        
        // First load the full dataset
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 300_000_000)
        let initialCount = viewModel.movies.count
        
        // When - enter a short keyword (2 characters or less)
        viewModel.keyword = "Li"
        try await Task.sleep(nanoseconds: 600_000_000)
        
        // Then
        #expect(viewModel.movies.count == initialCount, "Short keywords should not trigger search")
    }
    
    // MARK: - Movie Data Validation Tests
    @Test("movies contain expected data structure")
    func testMovieDataStructure() async throws {
        // Given
        let viewModel = createTestViewModel()
        
        // When
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 300_000_000)
        
        // Then
        #expect(!viewModel.movies.isEmpty, "Should have movies loaded")
        
        let movie = viewModel.movies.first!
        #expect(!movie.title.isEmpty, "Movie should have a title")
        #expect(!movie.detail.isEmpty, "Movie should have a detail/overview")
        #expect(movie.voteAverage >= 0, "Vote average should be non-negative")
        #expect(!movie.date.isEmpty, "Movie should have a release date")
        #expect(movie.imageUrl != nil, "Movie should have an image URL")
    }
    
    @Test("movie image URLs are properly constructed")
    func testMovieImageURLs() async throws {
        // Given
        let viewModel = createTestViewModel()
        
        // When
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 300_000_000)
        
        // Then
        let moviesWithImages = viewModel.movies.filter { $0.imageUrl != nil }
        #expect(!moviesWithImages.isEmpty, "Some movies should have image URLs")
        
        // Verify image URLs contain the base URL
        for movie in moviesWithImages {
            if let imageURL = movie.imageUrl {
                #expect(imageURL.absoluteString.contains(API.mediaBaseURL),
                       "Image URL should contain API base URL")
            }
        }
    }
    
    // MARK: - Refresh Tests
    @Test("refresh reloads data successfully")
    func testRefresh() async throws {
        // Given
        let viewModel = createTestViewModel()
        
        // Load initial data
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 300_000_000)
        let initialMovieIds = viewModel.movies.map { $0.id }
        
        // When
        viewModel.refresh()
        try await Task.sleep(nanoseconds: 300_000_000)
        
        // Then
        #expect(!viewModel.movies.isEmpty, "Movies should be reloaded after refresh")
        #expect(viewModel.state == .success, "State should be success after refresh")
        
        // Data should be the same since we're using the same JSON file
        let refreshedMovieIds = viewModel.movies.map { $0.id }
        #expect(initialMovieIds == refreshedMovieIds, "Movie IDs should match after refresh")
    }
    
    // MARK: - Integration Tests
    @Test("complete user workflow: load, search, clear search")
    func testCompleteWorkflow() async throws {
        // Given
        let viewModel = createTestViewModel()
        
        // Step 1: Initial load
        viewModel.fetchData()
        try await Task.sleep(nanoseconds: 300_000_000)
        #expect(viewModel.movies.count == 20, "Should load all movies initially")
        
        // Step 2: Perform search
        viewModel.keyword = "Mission"
        try await Task.sleep(nanoseconds: 800_000_000)
        let searchResults = viewModel.movies.count
        #expect(searchResults > 0, "Should find Mission movies")
        #expect(searchResults < 20, "Search results should be fewer than total")
        
        // Step 3: Clear search
        viewModel.keyword = ""
        try await Task.sleep(nanoseconds: 800_000_000)
        #expect(viewModel.movies.count == 20, "Should return to full list")
        
        // Step 4: Refresh
        viewModel.refresh()
        try await Task.sleep(nanoseconds: 800_000_000)
        #expect(viewModel.movies.count == 20, "Should maintain full list after refresh")
        #expect(viewModel.state == .success, "Final state should be success")
    }
}
