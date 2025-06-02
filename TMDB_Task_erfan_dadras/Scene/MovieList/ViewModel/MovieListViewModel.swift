//
//  MovieListViewModel.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Combine
import Foundation

/// View model responsible for managing movie list data and state
final class MovieListViewModel: BaseViewModel {
    
    // MARK: - Published Properties
    /// Array of movie UI models to display in the list
    @Published var movies: [MoviesUIModel] = []
    /// Current search keyword binding to UI
    @Published var keyword: String = ""
    /// Flag indicating if more data is available for pagination
    @Published var hasMoreData: Bool = false
    
    // MARK: - Private Properties
    /// Data source repository for fetching movie data
    private let dataSource: MoviesDatasourceRepo
    
    // MARK: - Initialization
    /// Initializes the view model with a data source
    /// - Parameter dataSource: Repository for movie data (defaults to production implementation)
    init(dataSource: MoviesDatasourceRepo = MoviesDatasource(network: .init(client: MoviesNetworkClient()))) {
        self.dataSource = dataSource
        super.init()
        bind()
    }
    
    // MARK: - Data Loading Methods
    /// Fetches movie data from the data source
    /// Updates the movies array and view state based on the result
    override func fetchData() {
        self.updateState(state: .loading)
        Task {
            do {
                let (data, hasMoreData) = try await dataSource.fetchData()
                mainThread {
                    self.hasMoreData = hasMoreData
                    self.movies = self.makeMoviesUnique(data)
                    self.updateState(state: data.isEmpty ? .noData : .success)
                }
            } catch {
                Logger.log(.error, error.localizedDescription)
                mainThread {
                    self.updateState(state: .failure(error: error))
                }
            }
        }
    }
    
    /// Refreshes the movie list data by resetting to first page
    /// Used for pull-to-refresh functionality
    func refresh() {
        self.updateState(state: .loading)
        Task {
            do {
                let (data, hasMoreData) = try await dataSource.refresh()
                mainThread {
                    self.hasMoreData = hasMoreData
                    self.movies = self.makeMoviesUnique(data)
                    self.updateState(state: data.isEmpty ? .noData : .success)
                }
            } catch {
                Logger.log(.error, error.localizedDescription)
                mainThread {
                    self.updateState(state: .failure(error: error))
                }
            }
        }
    }
    
    /// Loads more movies for infinite scrolling pagination
    /// Appends new data to existing movies array
    func loadMore() {
        guard self.state != .loadMore else { return }
        self.updateState(state: .loadMore)
        Task {
            do {
                let (data, hasMoreData) = try await dataSource.loadMoreData()
                mainThread {
                    self.hasMoreData = hasMoreData
                    let combinedMovies = self.movies + data
                    self.movies = self.makeMoviesUnique(combinedMovies)
                    self.updateState(state: self.movies.isEmpty ? .noData : .success)
                }
            } catch {
                Logger.log(.error, error.localizedDescription)
                //TODO: - throw an error
            }
        }
    }
    
    /// Performs search with the provided keyword
    /// Updates data source with keyword and fetches filtered results
    /// - Parameter keyword: Search term to filter movies
    private func search(with keyword: String) {
        self.updateState(state: .loading)
        self.dataSource.update(keyword: keyword)
        Task {
            do {
                let (data, hasMoreData) = try await dataSource.search()
                mainThread {
                    self.hasMoreData = hasMoreData
                    self.movies = self.makeMoviesUnique(data)
                    self.updateState(state: data.isEmpty ? .noData : .success)
                }
            } catch {
                Logger.log(.error, error.localizedDescription)
                mainThread {
                    self.updateState(state: .failure(error: error))
                }
            }
        }
    }
    
    // MARK: - Utility Methods
    /// Removes duplicate movies based on their unique ID
    /// - Parameter movies: Array of movies that may contain duplicates
    /// - Returns: Array of unique movies based on ID
    private func makeMoviesUnique(_ movies: [MoviesUIModel]) -> [MoviesUIModel] {
        var uniqueMovies: [MoviesUIModel] = []
        var seenIds: Set<Int> = []
        
        for movie in movies {
            if !seenIds.contains(movie.id) {
                uniqueMovies.append(movie)
                seenIds.insert(movie.id)
            }
        }
        
        return uniqueMovies
    }
}

// MARK: - Reactive Bindings
extension MovieListViewModel{
    /// Sets up reactive bindings for search functionality
    /// Implements debounced search with 500ms delay to avoid excessive API calls
    private func bind() {
        $keyword
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main) // Debounce for 500ms
            .removeDuplicates() // Avoid triggering fetch for the same value
            .map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
            .sink { [weak self] keyword in
                guard let self else { return }
                if keyword.isEmpty {
                    // Clear search mode and fetch regular movie list
                    self.dataSource.update(keyword: nil)
                    self.fetchData()
                } else if keyword.count > 2 {
                    // Perform search only if keyword has more than 2 characters
                    self.search(with: keyword)
                }
            }
            .store(in: &bag)
    }
}
