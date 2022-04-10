//
//  Persistence.swift
//  Shared
//
//  Persistent storage controller class for storing/deleting/updating entities in Core Data
//

import CoreData

struct PersistenceController {
    // shared persistence controller instance
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Song(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    static let unitTest: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        //empty store
        return result
    }()

    // persistence container
    let container: NSPersistentContainer

    // initializes container with Core Data database
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Database")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
