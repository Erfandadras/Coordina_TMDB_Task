
import Foundation

protocol DataParser {
    associatedtype T: Codable
    func mapData(result: Data, response: HTTPURLResponse) throws -> T
}
