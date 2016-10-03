//
//  UserController.swift
//  TicTracExample
//
//  Created by Dario Carlomagno on 06/08/16.
//  Copyright © 2016 Dario Carlomagno. All rights reserved.
//

import Foundation

struct UserController {
    
    static func getUsersList(fetchFromServer: Bool = true,
                             completion: ([UserModel]?) -> Void) {
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
    
    static func storeUser(name: String?,
                          email: String?,
                          infos: String?) {
        
        let userParameters = ["name" : name,
                              "email" : email,
                              "infos" : infos] as [String : AnyObject?]
        
        PersistenceManager.createUser(userParameters)
    }
    
    static func deleteAllUsers() {
        PersistenceManager.batchDelete()
    }
    
    static func refreshUsersList(completion: ([UserModel]?) -> Void) {
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