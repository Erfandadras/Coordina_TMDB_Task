//
//  MovieUIModel.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

struct MoviesUIModel: Identifiable {
    // MARK: - properties
    let id: Int
    let title: String
    let detail: String
    let voteAverage: Double
    let imageUrl: URL?
    let date: String
    
    // MARK: - init
    init(id: Int, title: String, detail: String, voteAverage: Double, imageUrl: URL?, date: String?) {
        self.id = id
        self.title = title
        self.detail = detail
        self.voteAverage = voteAverage
        self.imageUrl = imageUrl
        self.date = date ?? ""
    }
    
    
    // MARK: - init with row data
    init(with data: MovieRM) {
        self.id = data.id
        self.title = data.title
        self.detail = data.overview
        self.voteAverage = data.voteAverage
        self.date = data.date
        if let imagePath = data.imagePath {
            self.imageUrl = URL(string: API.mediaBaseURL + imagePath)
        } else {
            self.imageUrl = nil
        }
    }
}
