//
//  Bundle+decode.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

extension Bundle {
    /// Decodes a JSON file from the app bundle into a specified Decodable type
    /// - Parameters:
    ///   - file: Name of the file (without extension)
    ///   - withExtension: File extension (defaults to "json")
    /// - Returns: Decoded object of type T
    /// - Throws: NSError if file is not found, cannot be loaded, or fails to decode
    func decode<T: Decodable>(_ file: String, withExtension: String = "json") throws -> T {
        guard let url = self.url(forResource: file, withExtension: withExtension) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to locate \(file + withExtension) in bundle."])
        }

        guard let data = try? Data(contentsOf: url) else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load \(file) from bundle."])
        }

        return try data.decode()
    }
}
