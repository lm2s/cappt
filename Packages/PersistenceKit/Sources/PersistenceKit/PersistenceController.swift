@preconcurrency import CoreData
import Foundation

public final class PersistenceController: @unchecked Sendable {
    public static let preview = PersistenceController(inMemory: true)
    public static let shared = PersistenceController()

    public let container: NSPersistentContainer
    public private(set) var loadError: Error?

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
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        self.loadError = loadError

        if loadError == nil {
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
        self.container = container
    }

    public var viewContext: NSManagedObjectContext {
        self.container.viewContext
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
