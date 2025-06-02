import Foundation

protocol MoviesDatasourceRepo: AnyObject, BaseDataSource {
    func fetchData() async throws -> [MoviesUIModel]
    var keyword: String? {get set}
    var page: Int { get }
    var language: String { get }
}

final class MoviesDatasource: MoviesDatasourceRepo {
    // MARK: - properties
    private(set) var page: Int = 1
    private var uiModels: [MoviesUIModel] = []
    private var result: PaginateMoviesResponseModel?
    private let userManager = UserManager.shared
    private(set) var language: String
    var keyword: String?
    let network: NetworkClientImpl<MoviesNetworkClient>
    // MARK: - init
    init(network: NetworkClientImpl<MoviesNetworkClient>) {
        self.network = network
        self.language = userManager.language
    }
}

// MARK: - request logic
extension MoviesDatasource {
    func fetchData() async throws -> [MoviesUIModel] {
        self.page = 1
        
        let setup = createNetworkSetup(for: page)
        let data = try await network.fetch(setup: setup)
        self.result = data
        self.uiModels = data.results.map({.init(with: $0)})
        return uiModels
    }
    
    func loadMoreData() async throws -> [MoviesUIModel] {
        guard let result else { return []}
        let page: Int
        if let currentPage = result.page, result.hasMoreData {
            page = currentPage + 1
        } else {
            return []
        }
        
        let setup = createNetworkSetup(for: page)
        let data = try await network.fetch(setup: setup)
        self.page = data.page ?? self.page
        let uiModels: [MoviesUIModel] = data.results.map({.init(with: $0)})
        self.uiModels += uiModels
        return uiModels
    }
}

// MARK: - private logic
private extension MoviesDatasource {
    func createNetworkSetup(for page: Int = 1) -> NetworkSetup {
        if let keyword { // create setup for search movie list
            return createSearchNetworkSetup(for: page, keyword: keyword)
        } else { // create setup for normal movie list
            var params = createDefaultParams(for: page)
            params.updateValue("popularity.desc", forKey: "sort_by")
            params.updateValue("false", forKey: "include_video")
            
            let headers = createHeader()
            return .init(route: API.Routes.movieList, params: params, method: .get, headers: headers)
        }
    }
    
    func createSearchNetworkSetup(for page: Int = 1, keyword: String) -> NetworkSetup {
        var params = createDefaultParams(for: page)
        params.updateValue(keyword, forKey: "query")
        let headers = createHeader()
        return .init(route: API.Routes.search, params: params, method: .get, headers: headers)
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
        return ["authorization": "Bearer \(userManager.token ?? "")"]
    }
}
