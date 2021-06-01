//
//  DataSource.swift
//  ChatServer
//
//  Created by Admin on 02.06.2021.
//

import Foundation
import BSDSocketWrapperMac

class ServerDataSource{
    
    typealias Login = String
    var activeUsers = Dictionary<Login,ClientEndpoint>()
    var chats : Dictionary<UUID,Chat>
    var usersCredentials : Dictionary<Login,String>
    var contacts : Dictionary<Login,Contact>
    
    init() {
        self.chats = Dictionary<UUID,Chat>()
        self.usersCredentials = Dictionary<String,String>()
        self.contacts =  Dictionary<Login,Contact>()
    }
    
}


