@preconcurrency import CoreData
import Foundation

public final class PersistenceController: @unchecked Sendable {
    public static let preview = PersistenceController(inMemory: true)
    public static let shared = PersistenceController()
    
    public let container: NSPersistentContainer
    
    public init(inMemory: Bool = false) {
        let container = NSPersistentContainer(
            name: "CapptModel",
            managedObjectModel: Self.managedObjectModel
        )
        let description = container.persistentStoreDescriptions.first ?? NSPersistentStoreDescription()
        
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load Core Data store: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.container = container
    }
    
    public var viewContext: NSManagedObjectContext {
        self.container.viewContext
    }

    public func fetchFavoriteBreedIDs() async throws -> Set<String> {
        let context = self.container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return try await context.perform {
            let request = FavoriteBreedObject.fetchRequest()
            let favorites = try context.fetch(request)
            return Set(favorites.map(\.breedID))
        }
    }

    public func setFavoriteBreed(id: String, isFavorite: Bool) async throws {
        let context = self.container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        try await context.perform {
            let request = FavoriteBreedObject.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "breedID == %@", id)
            let favorite = try context.fetch(request).first

            if isFavorite {
                let object = favorite ?? FavoriteBreedObject(context: context)
                object.breedID = id
            } else if let favorite {
                context.delete(favorite)
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }
    
    private static let managedObjectModel: NSManagedObjectModel = {
        let breedID = NSAttributeDescription()
        breedID.name = "breedID"
        breedID.attributeType = .stringAttributeType
        breedID.isOptional = false

        let entity = NSEntityDescription()
        entity.name = "FavoriteBreedObject"
        entity.managedObjectClassName = NSStringFromClass(FavoriteBreedObject.self)
        entity.properties = [breedID]
        entity.uniquenessConstraints = [["breedID"]]

        let model = NSManagedObjectModel()
        model.entities = [entity]
        return model
    }()
}

@objc(FavoriteBreedObject)
final class FavoriteBreedObject: NSManagedObject {
    @NSManaged var breedID: String

    @nonobjc
    static func fetchRequest() -> NSFetchRequest<FavoriteBreedObject> {
        NSFetchRequest<FavoriteBreedObject>(entityName: "FavoriteBreedObject")
    }
}
