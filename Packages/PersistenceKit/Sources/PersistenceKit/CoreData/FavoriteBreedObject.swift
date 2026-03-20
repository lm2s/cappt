import CoreData
import Foundation

@objc(FavoriteBreedObject)
final class FavoriteBreedObject: NSManagedObject {
    @NSManaged var breedID: String

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<FavoriteBreedObject> {
        NSFetchRequest<FavoriteBreedObject>(entityName: "FavoriteBreedObject")
    }
}
