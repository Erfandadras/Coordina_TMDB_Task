//
//  NetworkClient.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//



import Foundation

enum NetworkClientError: Error {
    case typeError
}

class NetworkClientImpl<Client: NetworkClient> {
    let client: Client
    typealias T = Client.T
    
    init(client: Client) {
        self.client = client
    }
    
    func fetch(setup: NetworkSetup) async throws -> T {
        try await client.fetch(setup: setup)
    }
}


protocol NetworkClient: DataParser {
    func fetch(setup: NetworkSetup) async throws -> T
}

extension NetworkClient {
    var queue : DispatchQueue { DispatchQueue(label: "NetworkClient", qos: .background, attributes: .concurrent, target: .main)}
    
    func mapData(result: Data, response: HTTPURLResponse) throws -> T {
        if response.statusCode == 204 {
            Logger.log(.error, "204 -> no data")
            throw CustomError(description: "204 -> no data")
        }
        
        if response.statusCode == 200 {
#if DEBUG
            return try result.decode()
#else
            do {
                return try result.decode()
            } catch {
                throw CustomError(description: "Failed to decode data")
            }
#endif
        } else {
            throw CustomError(description: "error code \(response.statusCode)")
        }
    }
}
