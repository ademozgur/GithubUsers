import CoreData
import Foundation

protocol UserListViewModelCoordinatorDelegate: AnyObject {
    func didSelectUser(userId: NSManagedObjectID)
}
