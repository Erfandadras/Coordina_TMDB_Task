//
//  NetworkService.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

/// Main networking service class for handling HTTP requests
/// Can be extended to support additional features like file uploads
final class NetworkService: NSObject {}

/// we can also use Alamofire for making requests
/// add other functions here -> Upload
// MARK: - Generic Network Fetching
extension NetworkService {
    /// Performs a network request using a generic parser that conforms to DataParser
    /// - Parameters:
    ///   - dump: The data parser instance that will handle response mapping
    ///   - setup: Network configuration containing URL, headers, method, etc.
    /// - Returns: Parsed data of the type specified by the parser
    /// - Throws: CustomError for network failures, invalid URLs, or parsing errors
    static func fetch<parser: DataParser>(parser dump: parser, setup: NetworkSetup) async throws -> parser.T {
        var url: URLRequest
        
        // Convert network setup to URLRequest
        do {
            url = try setup.asUrlRequest()
        } catch let error {
            throw CustomError(description: error.localizedDescription)
        }
        
        // Perform the network request
        let (result, response) = try await URLSession.shared.data(for: url)
        
        // Validate response and parse data
        if let httpResponse = response as? HTTPURLResponse {
            if setup.range.contains(httpResponse.statusCode) {
                // Status code is within acceptable range, parse the data
                return try dump.mapData(result: result, response: httpResponse)
            } else {
                // Status code is outside acceptable range
                throw CustomError(description: "No valid status code")
            }
        } else {
            // Response is not an HTTP response
            throw CustomError(description: "No Http response")
        }
    }
}
