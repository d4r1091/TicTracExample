//
//  UserModel.swift
//  TicTracExample
//
//  Created by Dario Carlomagno on 06/08/16.
//  Copyright © 2016 Dario Carlomagno. All rights reserved.
//

import Foundation

struct UserModel {
    var email: String?
    var  name: String?
    var infos: String?
    
    init(email: String?, name: String?, infos: String?) {
        self.email = email
        self.name = name
        self.infos = infos
    }
}