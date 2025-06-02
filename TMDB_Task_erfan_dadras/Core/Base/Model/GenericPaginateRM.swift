//
//  GenericPaginateRM.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

struct GenericPaginateRM<T: Decodable>: Decodable {
    // MARK: - properties
    let page: Int?
    var results: [T]
    private let totalPages: Int?
    private let totalResults: Int?
    
    // variable
    var hasMoreData: Bool { page != totalPages }
    
    // MARK: - keys
    enum CodingKeys: String, CodingKey {
        case page = "page"
        case results = "results"
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page = try container.decodeIfPresent(Int.self, forKey: .page)
        self.results = try container.decode([T].self, forKey: .results)
        self.totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages)
        self.totalResults = try container.decodeIfPresent(Int.self, forKey: .totalResults)
    }
}
