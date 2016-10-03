//
//  MappableUser.swift
//  TicTracExample
//
//  Created by Dario Carlomagno on 06/08/16.
//  Copyright © 2016 Dario Carlomagno. All rights reserved.
//

import Foundation
import ObjectMapper

final class MappableUser: Mappable {
    var email: String?
    var  name: String?
    var infos: String?
    
    /*
     I assumed all of these fields as optional 'cause
     I don't have any kind of Model Specification's Document
     */
    
    init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        email <- map["email"]
        name <- map["name"]
        infos <- map["infos"]
    }
}

final class UsersResponse: Mappable {
    var users: [MappableUser]?
    
    init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        users <- map["users"]
    }
}