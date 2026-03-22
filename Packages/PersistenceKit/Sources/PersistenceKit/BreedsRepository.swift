@preconcurrency import CoreData

/// Reads and writes breeds from persistence.
public struct BreedsRepository: Sendable {
    private let controller: PersistenceController
    private let backgroundContext: NSManagedObjectContext

    /// Creates a repository backed by the given persistence controller.
    public init(controller: PersistenceController) {
        self.controller = controller
        let context = controller.container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        self.backgroundContext = context
    }

    /// Loads all saved breeds sorted by name.
    public func fetchBreeds() async throws -> [Breed] {
        let context = controller.viewContext

        return try await context.perform {
            let request = BreedMO.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            let objects = try context.fetch(request)
            return objects.map { object in
                Breed(
                    description: object.breedDescription,
                    id: object.breedID,
                    imageURL: object.imageURL,
                    isFavorite: object.isFavorite,
                    lifeSpanLowerBound: object.lifeSpanLowerBound == 0 ? nil : Int(object.lifeSpanLowerBound),
                    lifeSpanUpperBound: object.lifeSpanUpperBound == 0 ? nil : Int(object.lifeSpanUpperBound),
                    name: object.name,
                    origin: object.origin,
                    temperament: object.temperament
                )
            }
        }
    }

    /// Inserts or updates the provided breeds.
    public func saveBreeds(_ breeds: [Breed]) async throws {
        let context = backgroundContext

        try await context.perform {
            for breed in breeds {
                let request = BreedMO.fetchRequest()
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "breedID == %@", breed.id)
                let existing = try context.fetch(request).first

                let object = existing ?? BreedMO(context: context)
                object.breedID = breed.id
                object.breedDescription = breed.description
                object.imageURL = breed.imageURL
                object.isFavorite = breed.isFavorite
                object.lifeSpanLowerBound = Int16(breed.lifeSpanLowerBound ?? 0)
                object.lifeSpanUpperBound = Int16(breed.lifeSpanUpperBound ?? 0)
                object.name = breed.name
                object.origin = breed.origin
                object.temperament = breed.temperament
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }

    /// Updates the favorite state for a saved breed.
    public func setFavoriteBreed(id: String, isFavorite: Bool) async throws {
        let context = controller.viewContext

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
}
