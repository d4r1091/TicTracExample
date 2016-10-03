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
    
    private static let momd = "TicTracExample"
    private static let sqlite = "TicTracExampleCoreData.sqlite"
    
    // MARK: - Core Data stack
    
    static var context: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = PersistenceManager.persistentStoreCoordinator
        managedObjectContext.undoManager = nil
        return managedObjectContext
    }()
    
    private static var managedModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(momd, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    private static var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: PersistenceManager.managedModel)
        let url = PersistenceManager.applicationDocumentsDirectory.URLByAppendingPathComponent(sqlite)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                       NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                                                       configuration: nil,
                                                       URL: url,
                                                       options: nil)
        } catch {
            fatalError("Error: \(error)")
        }
        
        return coordinator
    }()
    
    // MARK: - Core Data Saving support
    
    static func save(inBackground: Bool = false) {
        guard context.hasChanges else { return }
        
        if inBackground {
            context.performBlock {
                PersistenceManager.privateSave()
                debugPrint("Saved in background")
            }
        } else {
            PersistenceManager.privateSave()
            debugPrint("Saved in foreground")
        }
        
    }
    
    private static func privateSave() {
        do {
            try context.save()
        } catch {
            fatalError("Error: \(error)")
        }
    }
    
    // MARK: - Utility
    
    private static var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
}