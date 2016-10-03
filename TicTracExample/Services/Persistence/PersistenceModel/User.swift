//
//  User.swift
//  TicTracExample
//
//  Created by Dario Carlomagno on 07/08/16.
//  Copyright © 2016 Dario Carlomagno. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {
    
    class func create(context: NSManagedObjectContext) -> User {
        return NSEntityDescription.insertNewObjectForEntityForName("User", inManagedObjectContext: context) as! User
    }
    
    class func fetchRequest() -> NSFetchRequest {
        return NSFetchRequest(entityName: "User")
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = NSDate()
    }
    
}