import CoreData
import Foundation

 var userEntityInitCounter: Int = 0

 @objc(UserEntity)
 public class UserEntity: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        userEntityInitCounter += 1
        // print("Init called! userEntityInitCounter: \(userEntityInitCounter)")
    }
 }
