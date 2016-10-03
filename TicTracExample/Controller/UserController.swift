//
//  UserController.swift
//  TicTracExample
//
//  Created by Dario Carlomagno on 06/08/16.
//  Copyright © 2016 Dario Carlomagno. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


struct UserController {
    
    static func getUsersList(_ fetchFromServer: Bool = true,
                             completion: @escaping ([UserModel]?) -> Void) {
        /*
         Probably it could be refactored
         normalizing the way I fill the array of UserModel
         */
        if fetchFromServer {
            NetworkManager.getUsersList { ( users: [MappableUser]?) in
                guard users?.count > 0 else {
                    completion(nil)
                    return
                }
                var userObjects: [UserModel] = []
                for anUser in users! {
                    let anUserObj = UserModel(email: anUser.email,
                        name: anUser.name,
                        infos: anUser.infos)
                    
                    // store user in Persistence
                    storeUser(anUserObj.name,
                        email: anUserObj.email,
                        infos: anUserObj.infos)
                    // -------------------------
                    
                    userObjects.append(anUserObj)
                }
                
                // save Persistence Context
                PersistenceManager.save()
                // ------------------------
                
                completion(userObjects)
            }
        } else {
            PersistenceManager.fetchRequestInBackground({ (users: [User]?) in
                guard users?.count > 0 else {
                    completion(nil)
                    return
                }
                var userObjects: [UserModel] = []
                for anUser in users! {
                    let anUserObj = UserModel(email: anUser.email,
                        name: anUser.name,
                        infos: anUser.infos)
                    userObjects.append(anUserObj)
                }
                completion(userObjects)
            })
        }
    }
    
    static func usersStored() -> Bool {
        let users = PersistenceManager.retriveUsers()
        return users.count > 0
    }
    
    static func storeUser(_ name: String?,
                          email: String?,
                          infos: String?) {
        
        let userParameters = ["name" : name as Optional<AnyObject>,
                              "email" : email as Optional<AnyObject>,
                              "infos" : infos as Optional<AnyObject>] as [String : AnyObject?]
        
        PersistenceManager.createUser(userParameters)
    }
    
    static func deleteAllUsers() {
        PersistenceManager.batchDelete()
    }
    
    static func refreshUsersList(_ completion: @escaping ([UserModel]?) -> Void) {
        deleteAllUsers()
        getUsersList { (users: [UserModel]?) in
            guard users?.count > 0 else {
                completion(nil)
                return
            }
            completion(users)
        }
    }
    
}
