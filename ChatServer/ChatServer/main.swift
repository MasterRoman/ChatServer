//
//  main.swift
//  ChatServer
//
//  Created by Admin on 01.06.2021.
//

import Foundation



func main(){
    var server : Server? = nil
    do{
        let serverDataSource = ServerDataSource()
        let handler = ServerHandler(dataSource: serverDataSource)
        serverDataSource.setHandler(handler: handler)
        server = try Server()
        if (server!.start()){
            while true {
                let client = server!.accept()
                guard let safeClient = client else {
                    return
                }
                let queue = DispatchQueue.global(qos: .utility)
                queue.async{
                    do {
                        let clientHandler = ClientHandler(clientSocket: safeClient, queue: queue, dataSource: serverDataSource)
                        clientHandler.start()
                    } catch (let error) {
                        print(error)
                        return
                    }
                    
                }
            }
        }
    }
    catch
    {
        server?.close()
        return
    }
}

main()

