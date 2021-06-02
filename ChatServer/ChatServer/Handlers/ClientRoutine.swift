//
//  ProcessRoutine.swift
//  ChatServer
//
//  Created by Admin on 01.06.2021.
//

import Foundation
import BSDSocketWrapperMac

class ClientHandler{
    
    private let clientSocket : ClientEndpoint
    private let queue : DispatchQueue
    private let dataSource : ServerDataSource
    
    lazy private var encoder = JSONEncoder()
    lazy private var decoder = JSONDecoder()
    
    init(clientSocket : ClientEndpoint,queue : DispatchQueue,dataSource : ServerDataSource) {
        self.clientSocket = clientSocket
        self.queue = queue
        self.dataSource = dataSource
    }
    
    func start(){
        receive()
    }
    
    func close(){
        do {
            try clientSocket.shutdown(with: .shutBoth)
            try clientSocket.close()
        } catch (let error) {
            print(error)
            return
        }
    }
    
    func receive() {
        while true {
            do{
                try clientSocket.receive({ data in
                    var res : SendReceiveProtocol
                    do {
                        res = try decoder.decode(SendReceiveProtocol.self, from: data)
                        switch res{
                        case .checkLogin(login: let login):
                            checkLogin(login: login)
                        case .registration(credentials : let credentials):
                            registration(credentials: credentials)
                        case .authorization(credentials : let credentials):
                            authorization(credentials: credentials)
                        case .newChat(chat: let chat):
                            makeNewChat(chat: chat)
                        case .newMessage(message: let message):
                            handleNewMessage(message: message)
                        case .offline(login: let login):
                            makeOffline(login: login)
                        case .newContact(login: let login, contact: let contact):
                            makeNewContact(by:login,contact:contact!)
                        }
                    } catch (let error) {
                        print(error)
                        return
                    }
                })
                
            } catch {
                print("Session closed")
                do {
                    try clientSocket.shutdown(with: .shutBoth)
                    try clientSocket.close()
                } catch {
                    return
                }
                return
            }
        }
    }
    
    func send(message : SendReceiveProtocol) throws {
        var data : Data
        do {
            data = try encoder.encode(message)
        } catch (let error) {
            print("encode failed: \(error)")
            return
        }
        
        try clientSocket.send(data: data)
    }
    
    func checkLogin(login : String){
        var answer : String = ""
        if (dataSource.usersCredentials.keys.contains(login)){
            answer = "BUSY"
        }
        else
        {
            dataSource.usersCredentials[login] = "WAIT"
            answer = login
        }
        do{
            try send(message: .checkLogin(login: answer))
        }
        catch (let error){
            print("send failed: \(error)")  //MARK: Think about saving
        }
    }
    
    func registration(credentials : Credentials){
        dataSource.usersCredentials[credentials.login] = credentials.password
        do{
            try send(message: .registration(credentials: credentials))
        }
        catch (let error){
            print("send failed: \(error)")  //MARK: Think about saving
        }
    }
    
    func authorization(credentials : Credentials){
        var result = "DENIED"
        let login = credentials.login
        if (dataSource.usersCredentials[login] == credentials.password){
            result = "APPROVED"
        }
        
        do{
            try send(message: .authorization(credentials: Credentials(login: result, password: result)))
            dataSource.activeUsers[login] = clientSocket
        }
        catch (let error){
            print("send failed: \(error)")  //MARK: Think about saving
        }
        
        
        
    }
    
    func makeNewChat(chat : Chat){
        dataSource.chats[chat.chatBody.chatId] = chat
        //MARK: !!!!! SEND TO ALL SENDERS!
        
    }
    
    func handleNewMessage(message : ChatBody){
        dataSource.newMessages[message.chatId]?.append(contentsOf: message.messages)
        //MARK: !!!!! SEND TO ALL SENDERS!
        
    }
    
    func makeOffline(login : String){
        dataSource.activeUsers[login] = nil
        close()
    }
    
    func makeNewContact(by login : String,contact : Contact){
        let contact = dataSource.contacts[login]
        
        do{
            try send(message: .newContact(login: login, contact: contact))
        }
        catch (let error){
            print("send failed: \(error)")  //MARK: Think about saving
        }
        
    }
    
    
}
