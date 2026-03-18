@preconcurrency import CoreData
import Foundation

@MainActor
public final class PersistenceController {
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
    
    private static let managedObjectModel: NSManagedObjectModel = {
        let model = NSManagedObjectModel()
        model.entities = []
        return model
    }()
}
