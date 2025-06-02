//
//  API.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

struct API {
    static let baseURL = "https://api.themoviedb.org/3/"
    static let mediaBaseURL = "https://image.tmdb.org/t/p/w500"
    static let apiKey = "4bb601c0652cfd758f8ef118d89508cd"
    static let token = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0YmI2MDFjMDY1MmNmZDc1OGY4ZWYxMThkODk1MDhjZCIsIm5iZiI6MTc0ODg0NTQyNS40ODE5OTk5LCJzdWIiOiI2ODNkNDM3MTcxMzk1Mjg0MzRhZDdmMjciLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0._OQRuEW0cjtjtdMlkkCdgxjOArpq58F2lh_HqghArzs"
    
    struct Routes {
        static let movieList = baseURL + "discover/movie"
    }
}
