//
//  Server.swift
//  ChatServer
//
//  Created by Admin on 01.06.2021.
//

import Foundation
import BSDSocketWrapperMac

class Server{
    static let port = "2786"
    
    let socket : ServerEndpoint
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    init() throws {
        self.socket = try ServerEndpoint(port: Server.port, sockType: .stream)
    }
    
    func start() -> Bool{
        do {
            try socket.bind()
            try socket.listen()
        } catch (let error) {
            print(error)
            return false
        }
        return true
    }
    
    
    func accept() -> ClientEndpoint?{
        do {
            let client : ClientEndpoint = try self.socket.accept()
            return client
        } catch (let error) {
            print(error)
            return nil
        }
        
    }
    
    func close(){
        do {
            try socket.shutdown(with: .shutBoth)
            try socket.close()
        } catch (let error) {
            print(error)
            return
        }
    }
    
    
    
}
