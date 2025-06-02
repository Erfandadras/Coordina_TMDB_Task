//
//  DataParser.swift
//  TMDB_Task_erfan_dadras
//
//  Created by Erfan mac mini on 6/2/25.
//



import Foundation

protocol DataParser {
    associatedtype T: Codable
    func mapData(result: Data, response: HTTPURLResponse) throws -> T
}
