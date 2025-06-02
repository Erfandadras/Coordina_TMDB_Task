//
//  NetworkSetup.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

/// Network-related error types
enum NetworkError: Error {
    case invalidURL
}

/// HTTP method types for network requests
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}


// MARK: - Network setup configuration
/// Configuration struct for setting up network requests
struct NetworkSetup {
    var route: String
    var params: [String: String]?
    var method: HTTPMethod
    var body: Data?
    var headers: [String: String]
    var range: FlattenSequence<[ClosedRange<Int>]>
    
    /// Initializes a network setup configuration
    /// - Parameters:
    ///   - route: The URL string for the request
    ///   - params: Query parameters as key-value pairs
    ///   - method: HTTP method (defaults to GET)
    ///   - body: Request body data for POST/PUT requests
    ///   - range: Acceptable HTTP status code ranges
    ///   - headers: Custom HTTP headers
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
    
    /// Converts the network setup into a URLRequest
    /// - Returns: Configured URLRequest ready for network call
    /// - Throws: NetworkError.invalidURL if URL construction fails
    func asUrlRequest() throws -> URLRequest {
        guard let url = URL(string: route) else {
            throw NetworkError.invalidURL
        }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        // Add query parameters if provided
        if let queryParams = params {
            urlComponents?.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        // Set default content type
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        for (key, value) in headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}
