//
//  UserStorage.swift
//  ChatServer
//
//  Created by Admin on 02.06.2021.
//

import Foundation

class UserData{
    private var chats : SafeDictionary<UUID,Chat>
    private var messages : SafeDictionary<UUID,ChatBody>
    private var contacts : [Contact]
    private var credentials : Credentials
    
    init(with login : String) {
        self.chats = SafeDictionary<UUID,Chat>()
        self.messages = SafeDictionary<UUID,ChatBody>()
        self.contacts = [Contact]()
        self.credentials = Credentials(login: login, password: "")
    }
    
    func addChat(chat : Chat){
        let id = chat.chatBody.chatId
        chats[id] = chat
        self.messages[id] = ChatBody(chatId: id, messages: [])
    }
    
    func removeChat(by id : UUID){
        chats[id] = nil
    }
    
    func addMessages(messages : ChatBody){
        let id = messages.chatId
        let chat = chats[id]
        guard let chatToAdd = chat else { return }
        chatToAdd.chatBody.messages.append(contentsOf: messages.messages)
        
        self.messages[id]?.messages.append(contentsOf: messages.messages)
    }
    
    func addContact(contact : Contact){
        contacts.append(contact)
    }
    
    func removeContact(by nickname : String){
        let index = contacts.firstIndex(where: {$0.login == nickname})
        if let index = index{
            contacts.remove(at: index)
        }
    }
    
    func setPassword(password : String){
        credentials.password = password
    }
    
    func checkPassword(password : String) -> Bool{
        if credentials.password == password{
            return true
        }
        return false
    }
}
