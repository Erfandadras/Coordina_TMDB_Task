//
//  MoviesResponseModel.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//



struct MoviesResponseModel: Codable {
    // MARK: - properties
    let id: Int
    let title: String
    let overview: String
    let voteAverage: Double
    let imagePath: String?
    let date: String
    
    // MARK: - keys
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case overview = "overview"
        case voteAverage = "vote_average"
        case imagePath = "poster_path"
        case date = "release_date"
    }
    
    // MARK: - normal init
    init(id: Int, title: String, overview: String, voteAverage: Double, imagePath: String?, date: String?) {
        self.id = id
        self.title = title
        self.overview = overview
        self.voteAverage = voteAverage
        self.imagePath = imagePath
        self.date = date ?? "unknown"
    }
    
    
    // MARK: - decoder init
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decodeIfPresent(String.self, forKey: .overview) ?? "unknown"
        voteAverage = try container.decodeIfPresent(Double.self, forKey: .voteAverage) ?? 0.0
        imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath)
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? "unknown"

    }
    
    /// add what ever you want to filter data
    func filter(with keyword: String) -> Bool {
        let keywordLower = keyword.lowercased()
        return title.lowercased().contains(keywordLower)
    }

}

