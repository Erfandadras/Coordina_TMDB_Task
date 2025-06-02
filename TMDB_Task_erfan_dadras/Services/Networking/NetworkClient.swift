//
//  NetworkClient.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

/// Error types specific to network client operations
enum NetworkClientError: Error {
    case typeError
}

/// Generic wrapper class for network client implementations
class NetworkClientImpl<Client: NetworkClient> {
    let client: Client
    typealias T = Client.T
    
    /// Initializes with a network client implementation
    /// - Parameter client: The concrete network client implementation
    init(client: Client) {
        self.client = client
    }
    
    /// Fetches data using the wrapped client
    /// - Parameter setup: Network configuration for the request
    /// - Returns: Decoded data of type T
    /// - Throws: Network or parsing errors
    func fetch(setup: NetworkSetup) async throws -> T {
        try await client.fetch(setup: setup)
    }
}

/// Protocol defining network client behavior with data parsing capabilities
protocol NetworkClient: DataParser {
    /// Performs network request and returns parsed data
    /// - Parameter setup: Network configuration for the request
    /// - Returns: Decoded data of type T
    /// - Throws: Network or parsing errors
    func fetch(setup: NetworkSetup) async throws -> T
}

extension NetworkClient {
    /// Background queue for network operations
    var queue : DispatchQueue { DispatchQueue(label: "NetworkClient", qos: .background, attributes: .concurrent, target: .main)}
    
    /// Maps raw network response data to the expected type
    /// - Parameters:
    ///   - result: Raw data from network response
    ///   - response: HTTP response with status codes and headers
    /// - Returns: Decoded data of type T
    /// - Throws: CustomError for various HTTP status codes or decoding failures
    func mapData(result: Data, response: HTTPURLResponse) throws -> T {
        // Handle no content response
        if response.statusCode == 204 {
            Logger.log(.error, "204 -> no data")
            throw CustomError(description: "204 -> no data")
        }
        
        // Handle successful response
        if response.statusCode == 200 {
#if DEBUG
            // In debug mode, let decoding errors bubble up for better debugging
            return try result.decode()
#else
            // In release mode, wrap decoding errors in custom error
            do {
                return try result.decode()
            } catch {
                throw CustomError(description: "Failed to decode data")
            }
#endif
        } else {
            // Handle other HTTP status codes
            throw CustomError(description: "error code \(response.statusCode)")
        }
    }
}
