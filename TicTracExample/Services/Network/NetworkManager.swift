//
//  NetworkManager.swift
//  TicTracExample
//
//  Created by Dario Carlomagno on 06/08/16.
//  Copyright © 2016 Dario Carlomagno. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

struct NetworkManager {
    
    private struct HTTPEndPoints {
        static let mainHTTPaddressPrefix = "http://media.tictrac.com/"
        static let usersList = mainHTTPaddressPrefix + "tmp/users.json"
    }
    
    static func getUsersList(callback: ([MappableUser]?) -> Void) {
        Alamofire.request(.GET, HTTPEndPoints.usersList).responseObject { (response: Response<UsersResponse, NSError> ) -> Void in
            let usersResponse = response.result.value
            guard usersResponse?.users?.count > 0 else {
                callback(nil)
                return
            }
            callback(usersResponse?.users)
        }
    }
}