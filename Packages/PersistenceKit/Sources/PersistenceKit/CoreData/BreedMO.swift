import CoreData
import Foundation

@objc(BreedMO)
final class BreedMO: NSManagedObject {
    @NSManaged var breedDescription: String
    @NSManaged var breedID: String
    @NSManaged var imageURL: String
    @NSManaged var isFavorite: Bool
    @NSManaged var name: String
    @NSManaged var origin: String
    @NSManaged var temperament: String

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<BreedMO> {
        NSFetchRequest<BreedMO>(entityName: "BreedMO")
    }
}
