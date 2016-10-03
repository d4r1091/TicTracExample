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
    
    static func retriveUsers(_ limit: Int? = nil) -> [User] {
        let itemsFetch = User.userFetchRequest()
        
        if let limit = limit {
            itemsFetch.fetchLimit = limit
        }
        
        do {
            let items =  try PersistenceManager.context.fetch(itemsFetch) as! [User]
            return items;
        } catch {
            fatalError("Failed to fetch items: \(error)")
        }
    }
    
    static func fetchRequestInBackground(_ callback: @escaping (_ users: [User]?) -> Void) {
        let fetchRequest = User.userFetchRequest()
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) {
            callback($0.finalResult as! [User])
        
        do {
            try PersistenceManager.context.execute(asynchronousFetchRequest) as! NSAsynchronousFetchResult
        } catch {
            fatalError("Failed to fetch users: \(error)")
        }
    }
    
    static func batchDelete() {
        PersistenceManager.save()
        let fetchRequest = User.userFetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        batchDeleteRequest.resultType = .resultTypeCount
        do {
            let batchDeleteResult = try PersistenceManager.context.execute(batchDeleteRequest) as! NSBatchDeleteResult
            debugPrint("The batch delete request has deleted \(batchDeleteResult.result!) records.")
            PersistenceManager.context.reset()
        } catch {
            fatalError("Failed to fetch dogs: \(error)")
        }
    }
    
    static func createUser(_ parameters: [String: AnyObject?]) {
        supportCreateUser(PersistenceManager.context, parameters: parameters)
        debugPrint("Created User")
    }
    
    fileprivate static func createUserInBackground(_ parameters: [String: AnyObject?]) {
        let context = PersistenceManager.context
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = context
        privateContext.perform {
            supportCreateUser(privateContext, parameters: parameters)
            do {
                try privateContext.save()
                debugPrint("Created Item In Background")
            } catch {
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    fileprivate static func supportCreateUser(_ contex: NSManagedObjectContext, parameters: [String : AnyObject?]) {
        let user = User.create(context)
        user.name = parameters["name"] as? String
        user.email = parameters["email"] as? String
        user.infos = parameters["infos"] as? String
    }
}
