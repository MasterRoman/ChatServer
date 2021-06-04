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
    case newMessage(ChatBody)
    case newContact(Contact)
}



class ServerDataSource{
    
    typealias Login = String
    
    private var chats : SafeDictionary<UUID,Chat>
    var users : SafeDictionary<Login,UserData>
    var contacts : SafeDictionary<Login,Contact>
    
    private var activeUsers = SafeDictionary<Login,ClientEndpoint>()
    private var offlineTasks = SafeDictionary<Login,UserData>()
    
    
    weak var handler : Handler!
    
    
    init() {
        self.chats = SafeDictionary<UUID,Chat>()
        self.users = SafeDictionary<Login,UserData>()
        self.contacts =  SafeDictionary<Login,Contact>()
    }
    
    
    func setHandler(handler : Handler) {
        self.handler = handler
    }
    
    deinit {
        //MARK: LOAD INTO DB
    }
    
    
    //////////
    
    func addActiveUser(login : String,socket : ClientEndpoint){
        activeUsers[login] = socket
        handler.newOnline(login: login, socket: socket)
    }
    
    func getActiveUser(by login : String) -> ClientEndpoint?{
        return activeUsers[login]
    }
    
    func removeActiveUser(by login : String){
        activeUsers[login] = nil
    }

    /////////
    
    func addNewChat(chat : Chat){
        let id = chat.chatBody.chatId
        self.chats[id] = chat
        
        handler.newChat(chat: chat)
        
    }
    
    func removeChat(by id : UUID){
        self.chats[id] = nil
    }
    
    func getChat(by id : UUID) -> Chat{
        return chats[id]!
    }
    
    
    ////////
    
    
    func addNewMessages(messages : ChatBody){
        let id = messages.chatId
        self.chats[id]?.chatBody.messages.append(contentsOf: messages.messages)
        
        handler.newMessage(message: messages)
        
     
        ///new every time!!!
    }
    
    ///////
    
    func addOfflineTask(for login : String,task : Task){
        var user =  offlineTasks[login]
        if user == nil {
            offlineTasks[login] = UserData(with: login)
            user = offlineTasks[login]
        }
        switch task {
        case .newChat(let chat):
            user!.addChat(chat: chat)
        case .newMessage(let message):
            user!.addMessages(messages: message)
        case .newContact(let contact):
            user!.addContact(contact: contact)
        }
        
    }
    
    func removeOfflineTask(for login : String){
        offlineTasks[login] = nil
    }
    
    func getOfflineTask(for login : String) -> UserData?{
        let userData = offlineTasks[login]
        return userData
    }
    
    //
    
    func addNewContact(contact : Contact,for login : String){
        
        
    }
 

    
    
}


