import Foundation

struct SearchResponse<T: Codable>: Codable {
    var items: [T]
}
