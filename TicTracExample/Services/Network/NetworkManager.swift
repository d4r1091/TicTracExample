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
    
    fileprivate struct HTTPEndPoints {
        static let mainHTTPaddressPrefix = "http://media.tictrac.com/"
        static let usersList = mainHTTPaddressPrefix + "tmp/users.json"
    }
    
    static func getUsersList(_ callback: @escaping ([MappableUser]?) -> Void) {
        Alamofire.request(HTTPEndPoints.usersList).responseJSON { response in
            let usersResponse = response.result.value as? UsersResponse
            guard usersResponse?.users != nil else {
                callback(nil)
                return
            }
            callback(usersResponse?.users)

        }
    }
}
