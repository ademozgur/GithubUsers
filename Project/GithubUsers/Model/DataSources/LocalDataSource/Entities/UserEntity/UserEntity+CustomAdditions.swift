import Foundation

extension UserEntity {
    func mapFrom(userDetails: UserDetails) {
        id = Int64(userDetails.id)
        avatarUrl = userDetails.avatarUrl
        followers = Int64(userDetails.followers ?? 0)
        location = userDetails.location
        login = userDetails.login
        name = userDetails.name
    }
}
