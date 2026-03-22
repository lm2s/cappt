@preconcurrency import CoreData
import Foundation

/// Builds and owns the Core Data stack for the app.
public final class PersistenceController: @unchecked Sendable {
    /// An in-memory controller for previews.
    public static let preview = PersistenceController(inMemory: true)
    /// The shared on-disk controller.
    public static let shared = PersistenceController()

    /// The persistent container backing the data store.
    public let container: NSPersistentContainer
    /// Any error produced while loading the persistent stores.
    public private(set) var loadError: Error?

    /// Creates a persistence controller.
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

    /// The main managed object context.
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
