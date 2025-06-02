//
//  DataParser.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

/// Protocol for parsing network response data into specific types
protocol DataParser {
    /// Associated type representing the expected decoded data type
    associatedtype T: Codable
    
    /// Maps raw network response data to the expected type
    /// - Parameters:
    ///   - result: Raw data from network response
    ///   - response: HTTP response containing status codes and headers
    /// - Returns: Decoded data of type T
    /// - Throws: Parsing or network-related errors
    func mapData(result: Data, response: HTTPURLResponse) throws -> T
}
