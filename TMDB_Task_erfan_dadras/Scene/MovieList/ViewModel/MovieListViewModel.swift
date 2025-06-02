//
//  MovieListViewModel.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Combine

/// View model responsible for managing movie list data and state
final class MovieListViewModel: BaseViewModel {
    
    // MARK: - Published Properties
    /// Array of movie UI models to display in the list
    @Published var movies: [MoviesUIModel] = []
    
    // MARK: - Private Properties
    /// Data source repository for fetching movie data
    private let dataSource: MoviesDatasourceRepo
    
    // MARK: - Initialization
    /// Initializes the view model with a data source
    /// - Parameter dataSource: Repository for movie data (defaults to production implementation)
    init(dataSource: MoviesDatasourceRepo = MoviesDatasource(network: .init(client: MoviesNetworkClient()))) {
        self.dataSource = dataSource
    }
    
    // MARK: - Data Loading Methods
    /// Fetches movie data from the data source
    /// Updates the movies array and view state based on the result
    override func fetchData() {
        Task {
            do {
                let data = try await dataSource.fetchData()
                mainThread {
                    self.movies = data
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
    
    /// Refreshes the movie list data
    /// TODO: Implement refresh functionality
    func refresh() {
        // Implementation needed for pull-to-refresh
    }
    
    /// Loads more movies for pagination
    /// TODO: Implement pagination functionality
    func loadMore() {
        // Implementation needed for infinite scrolling
    }
}
