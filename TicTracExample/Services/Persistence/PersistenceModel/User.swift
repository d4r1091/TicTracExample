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
    
    class func create(_ context: NSManagedObjectContext) -> User {
        return NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
    }
    
    class func userFetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest(entityName: "User")
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
}
