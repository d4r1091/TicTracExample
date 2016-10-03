//
//  PersistentManger+Operations.swift
//  TicTracExample
//
//  Created by Dario Carlomagno on 07/08/16.
//  Copyright © 2016 Dario Carlomagno. All rights reserved.
//

import Foundation
import CoreData

extension PersistenceManager {
    
    static func retriveUsers(limit: Int? = nil) -> [User] {
        let itemsFetch = User.fetchRequest()
        
        if let limit = limit {
            itemsFetch.fetchLimit = limit
        }
        
        do {
            let items =  try PersistenceManager.context.executeFetchRequest(itemsFetch) as! [User]
            return items;
        } catch {
            fatalError("Failed to fetch items: \(error)")
        }
    }
    
    static func fetchRequestInBackground(callback: (users: [User]?) -> Void) {
        let fetchRequest = User.fetchRequest()
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) {
            callback(users: $0.finalResult as? [User])
        }
        do {
            try PersistenceManager.context.executeRequest(asynchronousFetchRequest) as! NSAsynchronousFetchResult
        } catch {
            fatalError("Failed to fetch users: \(error)")
        }
    }
    
    static func batchDelete() {
        PersistenceManager.save()
        let fetchRequest = User.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .ResultTypeCount
        do {
            let batchDeleteResult = try PersistenceManager.context.executeRequest(batchDeleteRequest) as! NSBatchDeleteResult
            debugPrint("The batch delete request has deleted \(batchDeleteResult.result!) records.")
            PersistenceManager.context.reset()
        } catch {
            fatalError("Failed to fetch dogs: \(error)")
        }
    }
    
    static func createUser(parameters: [String: AnyObject?]) {
        supportCreateUser(PersistenceManager.context, parameters: parameters)
        debugPrint("Created User")
    }
    
    private static func createUserInBackground(parameters: [String: AnyObject?]) {
        let context = PersistenceManager.context
        let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.parentContext = context
        privateContext.performBlock {
            supportCreateUser(privateContext, parameters: parameters)
            do {
                try privateContext.save()
                debugPrint("Created Item In Background")
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    private static func supportCreateUser(contex: NSManagedObjectContext, parameters: [String : AnyObject?]) {
        let user = User.create(context)
        user.name = parameters["name"] as? String
        user.email = parameters["email"] as? String
        user.infos = parameters["infos"] as? String
    }
}