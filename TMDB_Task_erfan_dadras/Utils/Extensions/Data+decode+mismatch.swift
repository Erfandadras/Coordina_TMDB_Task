//
//  Data+decode+mismatch.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

extension Data {
    /// Decodes JSON data into a specified Decodable type with detailed error messages
    /// - Returns: Decoded object of type T
    /// - Throws: NSError with detailed decoding error information
    func decode<T: Decodable>() throws -> T {
        var errorMessage: String = ""
        
        do {
            let result = try JSONDecoder().decode(T.self, from: self)
            return result
        } catch let DecodingError.dataCorrupted(context) {
            // Handle corrupted data errors
            errorMessage = "\(context)"

        } catch let DecodingError.keyNotFound(key, context) {
            // Handle missing key errors with path information
            errorMessage = "Key '\(key)' not found: " + context.debugDescription
            errorMessage += "\n codingPath: \(context.codingPath)"
            
        } catch let DecodingError.valueNotFound(value, context) {
            // Handle missing value errors with path information
            errorMessage = "value '\(value)' not found: " + context.debugDescription
            errorMessage += "\n codingPath: \(context.codingPath)"

        } catch let DecodingError.typeMismatch(type, context)  {
            // Handle type mismatch errors with path information
            errorMessage = "Type '\(type)' mismatch: " + context.debugDescription
            errorMessage += "\n codingPath: \(context.codingPath)"

        } catch {
            // Handle any other decoding errors
            errorMessage = error.localizedDescription
            
        }
        throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
    }
}
