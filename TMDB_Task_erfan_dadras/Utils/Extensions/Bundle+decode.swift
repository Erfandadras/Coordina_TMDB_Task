//
//  Bundle+decode.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//

import Foundation

extension Bundle {
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
