//
//  User+Properties.swift
//  TicTracExample
//
//  Created by Dario Carlomagno on 07/08/16.
//  Copyright © 2016 Dario Carlomagno. All rights reserved.
//

import Foundation
import CoreData

extension User {
    @NSManaged var creationDate: NSDate?
    @NSManaged var email: String?
    @NSManaged var name: String?
    @NSManaged var infos: String?
}