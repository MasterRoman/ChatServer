//
//  DataSource.swift
//  ChatServer
//
//  Created by Admin on 02.06.2021.
//

import Foundation
import BSDSocketWrapperMac

enum Task {
    case newChat(Chat)
    case newMessage(Message)
    case newContact(Contact)
}

class ServerDataSource{
    
    typealias Login = String
    var activeUsers = Dictionary<Login,ClientEndpoint>()
    var chats : Dictionary<UUID,Chat>
    var usersCredentials : Dictionary<Login,String>
    var contacts : Dictionary<Login,Contact>
    
    var newMessages = Dictionary<UUID,[Message]>()
    var offlineTasks = Dictionary<Login,[Task]>()
    
    init() {
        self.chats = Dictionary<UUID,Chat>()
        self.usersCredentials = Dictionary<String,String>()
        self.contacts =  Dictionary<Login,Contact>()
    }
    
    
    deinit {
        //MARK: LOAD INTO DB
    }
    
}


