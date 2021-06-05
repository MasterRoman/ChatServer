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
        var stop = false
        while !stop {
            do{
                try clientSocket.receive({ data in
                    var res : SendReceiveProtocol
                    do {
                        if (data.count > 0){
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
                        }
                        else
                        {
                            stop = true
                            return
                        }
                    } catch (let error) {
                        print(error)
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
            data = try encoder.encode([message])
        } catch (let error) {
            print("encode failed: \(error)")
            return
        }
        
        try clientSocket.send(data: data)
    }
    
    func checkLogin(login : String){
        var answer : String = ""
        if dataSource.users[login] != nil{
            answer = "BUSY"
        }
        else
        {
            let user = UserData(with: login)
            user.setPassword(password: "WAIT")
            dataSource.users[login] = user
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
        var result = credentials
        if let localCredentials = dataSource.users[credentials.login] {
            if (localCredentials.checkPassword(password: "WAIT")){
                localCredentials.setPassword(password: credentials.password)
            }
        } else {
            result.password = "BUSY"
        }
        
        do{
            try send(message: .registration(credentials: result))
            dataSource.contacts[credentials.login] = Contact(with: credentials.login, name: "", surname: "")
        }
        catch (let error){
            print("send failed: \(error)")  //MARK: Think about saving
        }
    }
    
    
    func authorization(credentials : Credentials){
        var result = "DENIED"
        let login = credentials.login
        if let localCredentials = dataSource.users[login]{
            if localCredentials.checkPassword(password: credentials.password){
                result = "APPROVED"
                DispatchQueue.global(qos: .userInitiated).async {
                    do{
                        try self.send(message: .authorization(credentials: Credentials(login: result, password: result)))
                        
                    }
                    catch (let error){
                        print("send failed: \(error)")  //MARK: Think about saving
                    }
                }
                
                sleep(1)
                dataSource.addActiveUser(login: login, socket: self.clientSocket)
                
                return
            }
        }
        
        do{
            try send(message: .authorization(credentials: Credentials(login: result, password: result)))
            
        }
        catch (let error){
            print("send failed: \(error)")  //MARK: Think about saving
        }
        
    }
    
    func makeNewChat(chat : Chat){
        dataSource.addNewChat(chat: chat)
    }
    
    func handleNewMessage(message : ChatBody){
        dataSource.addNewMessages(messages: message)
    }
    
    func makeOffline(login : String){
        dataSource.removeActiveUser(by: login)
        //close()
    }
    
    func makeNewContact(by login : String,contact : Contact){
        dataSource.addNewContact(contact: contact, for: login)
        let contact = dataSource.contacts[login]
        
        do{
            try send(message: .newContact(login: login, contact: contact))
        }
        catch (let error){
            print("send failed: \(error)")  //MARK: Think about saving
        }
        
    }
    
}





