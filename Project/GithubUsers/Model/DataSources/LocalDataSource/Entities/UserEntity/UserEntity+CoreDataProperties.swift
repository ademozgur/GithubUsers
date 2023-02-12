import CoreData
import Foundation

extension UserEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var avatarUrl: String?
    @NSManaged public var followers: Int64
    @NSManaged public var id: Int64
    @NSManaged public var location: String?
    @NSManaged public var login: String?
    @NSManaged public var name: String?
}

extension UserEntity: Identifiable {
}
