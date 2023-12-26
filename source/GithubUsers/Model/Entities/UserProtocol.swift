import Foundation

protocol UserProtocol: Hashable {
    var id: Int64 { get }
    var login: String? { get }
    var avatarUrl: String? { get }
}
