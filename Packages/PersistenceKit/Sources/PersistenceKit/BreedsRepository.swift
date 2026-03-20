@preconcurrency import CoreData

public struct BreedsRepository: Sendable {
    private let controller: PersistenceController

    public init(controller: PersistenceController) {
        self.controller = controller
    }

    public func fetchBreeds() async throws -> [Breed] {
        let context = controller.container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

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
                    name: object.name,
                    origin: object.origin,
                    temperament: object.temperament
                )
            }
        }
    }

    public func saveBreeds(_ breeds: [Breed]) async throws {
        let context = controller.container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

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
        let context = controller.container.newBackgroundContext()
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
}
