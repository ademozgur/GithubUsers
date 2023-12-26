import Foundation

struct UserDetails: Codable, Hashable, DictionaryConvertible, UserProtocol {
    var id: Int64
    var login: String?
    var avatarUrl: String?
    var name: String?
    var followers: Int?
    var location: String?

    enum CodingKeys: String, CodingKey {
        case id, login, name, followers, location
        case avatarUrl = "avatar_url"
    }
}
