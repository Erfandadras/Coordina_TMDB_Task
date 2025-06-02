//
//  MoviesDatasourceRepo.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//


import Foundation

protocol MoviesDatasourceRepo: AnyObject {
    func fetchData() async throws -> [MoviesUIModel]
    func refresh() async throws -> [MoviesUIModel]
    func loadMoreData() async throws -> [MoviesUIModel]
    var language: String { get }
}

final class MoviesDatasource: MoviesDatasourceRepo {
    // MARK: - properties
    private(set) var page: Int = 1
    private(set) var language: String
    private var completed: Bool = false
    let network: NetworkClientImpl<MoviesNetworkClient>
    
    // MARK: - init
    init(network: NetworkClientImpl<MoviesNetworkClient>) {
        self.network = network
        self.language = "en"
    }
}

// MARK: - request logic
extension MoviesDatasource {
    func fetchData() async throws -> [MoviesUIModel] {
        self.page = 1
        let setup = createNetworkSetup(for: page)
        let data = try await network.fetch(setup: setup)
        self.page = data.page ?? 1
        self.completed = !data.hasMoreData
        return data.results.map({.init(with: $0)})
    }
    
    func loadMoreData() async throws -> [MoviesUIModel] {
        guard !completed else { return [] }
        let setup = createNetworkSetup(for: page + 1)
        let data = try await network.fetch(setup: setup)
        self.page = data.page ?? self.page
        self.completed = !data.hasMoreData
        let uiModels: [MoviesUIModel] = data.results.map({.init(with: $0)})
        return uiModels
    }
    
    func refresh() async throws -> [MoviesUIModel] {
        self.page = 1
        self.completed = false
        return try await fetchData()
    }
}

// MARK: - private logic
private extension MoviesDatasource {
    func createNetworkSetup(for page: Int = 1) -> NetworkSetup {
        var params = createDefaultParams(for: page)
        params.updateValue("popularity.desc", forKey: "sort_by")
        params.updateValue("false", forKey: "include_video")
        
        let headers = createHeader()
        return .init(route: API.Routes.movieList, params: params, method: .get, headers: headers)
    }
    
    func createDefaultParams(for page: Int) -> [String: String] {
        return [
            "include_adult": "false",
            "include_video": "false",
            "language": language,
            "page": "\(page)",
          ]
    }
    private func createHeader() -> [String: String] {
        return ["authorization": "Bearer \(API.token)"]
    }
}
