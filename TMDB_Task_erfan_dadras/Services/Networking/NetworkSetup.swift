//
//  NetworkError.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}


// MARK: - network setup
struct NetworkSetup {
    var route: String
    var params: [String: String]?
    var method: HTTPMethod
    var body: Data?
    var headers: [String: String]
    var range: FlattenSequence<[ClosedRange<Int>]>
    
    init(route: String,
         params: [String: String]? = nil,
         method: HTTPMethod = .get,
         body: Data? = nil,
         range: FlattenSequence<[ClosedRange<Int>]> = [200...400, 402...500].joined(),
         headers: [String: String] = [:]) {
        self.route = route
        self.params = params
        self.method = method
        self.body = body
        self.range = range
        self.headers = headers
    }
    
    func asUrlRequest() throws -> URLRequest {
        guard let url = URL(string: route) else {
            throw NetworkError.invalidURL
        }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let queryParams = params {
            urlComponents?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}
