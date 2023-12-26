import Foundation

struct Routes {
    static let usersPath = "/users"

    static func singleUserPath(userId: String) -> String {
        usersPath + "/" + userId
    }
}
