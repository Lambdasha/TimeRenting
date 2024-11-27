//
//  Persistence.swift
//  TimeRenting
//
//  Created by Echo Targaryen on 10/28/24.
//


import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TimeRentingDataModel") // Make sure this name matches your .xcdatamodeld file
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // Expose the context for use in the app
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
}
