//
//  ServerRoutine.swift
//  ChatServer
//
//  Created by Admin on 02.06.2021.
//

import Foundation
import BSDSocketWrapperMac

class ServerHandler : Handler{
    
    
    private let dataSource : ServerDataSource
    
    lazy private var encoder = JSONEncoder()
    
    init(dataSource : ServerDataSource) {
        self.dataSource = dataSource
    }
    
    func start() {
        
    }
    
    func newChat(chat: Chat) {
        let senders = chat.senders
        var login = String()
        var socket : ClientEndpoint?
        for index in 1...senders.count - 1 {
            login = senders[index].senderId
            socket = dataSource.getActiveUser(by: login)
            
            let copyChat = chat.copy() as! Chat
            if let endPoint = socket{
                if !send(clientSocket: endPoint, message: .newChat(chat: chat)){
                    //add to offline task ???
                }
            }
            else
            {
                dataSource.addOfflineTask(for: login, task: Task.newChat(copyChat))
            }
        }
    }
    
    func newMessage(message: ChatBody) {
        let id = message.chatId
        let messageSender = message.messages.first!.sender.senderId
        let senders = dataSource.getChat(by: id).senders
        
        var login = String()
        var socket : ClientEndpoint?
        for sender in senders {
            if (sender.senderId != messageSender){
                login = sender.senderId
                socket = dataSource.getActiveUser(by: login)
                if let endPoint = socket{
                    if !send(clientSocket: endPoint, message: .newMessage(message: message)){
                        //add to offline task ???
                    }
                }
                else
                {
                    dataSource.addOfflineTask(for: login, task: Task.newMessage(message))
                }
            }
        }
    }
    

    
    func newOnline(login: String, socket: ClientEndpoint) {
        let data = dataSource.getOfflineTask(for: login)
        guard let userData = data else {
            return
        }
        
        let chats = userData.getChats()
        for chat in chats{
            if (!send(clientSocket: socket, message: .newChat(chat: chat))){   //MARK: Think about safety
                dataSource.addOfflineTask(for: login, task: .newChat(chat))
                break
            }
        }
        
        let messages = userData.getMessages()
        for message in messages{
            if (!send(clientSocket: socket, message: .newMessage(message: message))){   //MARK: Think about safety
                dataSource.addOfflineTask(for: login, task: .newMessage(message))
                break
            }
        }
        
        let contacts = userData.getContacts()
        for contact in contacts{
            if (!send(clientSocket: socket, message: .newContact(login: login, contact: contact))){   //MARK: Think about safety
                dataSource.addOfflineTask(for: login, task: .newContact(contact))
                break
            }
        }
        
        dataSource.removeOfflineTask(for: login)
        
    }
    
    
    func send(clientSocket : ClientEndpoint,message : SendReceiveProtocol) -> Bool {
        var data : Data
        do {
            data = try encoder.encode(message)
            try clientSocket.send(data: data)
        } catch (let error) {
            print("failed: \(error)")
            return false
        }
        return true
    }
    
    deinit {
        //remove observers
    }
}
