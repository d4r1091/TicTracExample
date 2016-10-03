//
//  PersistenceManger.swift
//  TicTracExample
//
//  Created by Dario Carlomagno on 06/08/16.
//  Copyright © 2016 Dario Carlomagno. All rights reserved.
//

import Foundation
import CoreData

struct PersistenceManager {
    
    fileprivate static let momd = "TicTracExample"
    fileprivate static let sqlite = "TicTracExampleCoreData.sqlite"
    
    // MARK: - Core Data stack
    
    static var context: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = PersistenceManager.persistentStoreCoordinator
        managedObjectContext.undoManager = nil
        return managedObjectContext
    }()
    
    fileprivate static var managedModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: momd, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    fileprivate static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: PersistenceManager.managedModel)
        let url = PersistenceManager.applicationDocumentsDirectory.appendingPathComponent(sqlite)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                       configurationName: nil,
                                                       at: url,
                                                       options: nil)
        } catch {
            fatalError("Error: \(error)")
        }
        
        return coordinator
    }()
    
    // MARK: - Core Data Saving support
    
    static func save(_ inBackground: Bool = false) {
        guard context.hasChanges else { return }
        
        if inBackground {
            context.perform {
                PersistenceManager.privateSave()
                debugPrint("Saved in background")
            }
        } else {
            PersistenceManager.privateSave()
            debugPrint("Saved in foreground")
        }
        
    }
    
    fileprivate static func privateSave() {
        do {
            try context.save()
        } catch {
            fatalError("Error: \(error)")
        }
    }
    
    // MARK: - Utility
    
    fileprivate static var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
}
