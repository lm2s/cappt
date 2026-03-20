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

    public func fetchBreeds() async throws -> [CachedBreed] {
        let context = self.container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return try await context.perform {
            let request = BreedMO.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let objects = try context.fetch(request)
            return objects.map { object in
                CachedBreed(
                    breedDescription: object.breedDescription,
                    id: object.breedID,
                    imageURL: object.imageURL,
                    isFavorite: object.isFavorite,
                    name: object.name,
                    origin: object.origin,
                    temperament: object.temperament
                )
            }
        }
    }

    public func saveBreeds(_ breeds: [CachedBreed]) async throws {
        let context = self.container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        try await context.perform {
            for breed in breeds {
                let request = BreedMO.fetchRequest()
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "breedID == %@", breed.id)
                let existing = try context.fetch(request).first

                let object = existing ?? BreedMO(context: context)
                object.breedID = breed.id
                object.breedDescription = breed.breedDescription
                object.imageURL = breed.imageURL
                object.isFavorite = existing?.isFavorite ?? breed.isFavorite
                object.name = breed.name
                object.origin = breed.origin
                object.temperament = breed.temperament
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }

    public func setFavoriteBreed(id: String, isFavorite: Bool) async throws {
        let context = self.container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        try await context.perform {
            let request = BreedMO.fetchRequest()
            request.fetchLimit = 1
            request.predicate = NSPredicate(format: "breedID == %@", id)

            if let object = try context.fetch(request).first {
                object.isFavorite = isFavorite
                if context.hasChanges {
                    try context.save()
                }
            }
        }
    }

    private static let managedObjectModel: NSManagedObjectModel = {
        guard
            let url = Bundle.module.url(forResource: "CapptModel", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url)
        else {
            fatalError("Failed to load Core Data model")
        }
        return model
    }()
}
