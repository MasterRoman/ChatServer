//
//  ServerRoutine.swift
//  ChatServer
//
//  Created by Admin on 02.06.2021.
//

import Foundation

class ServerHandler{
    
    private let dataSource : ServerDataSource
    
    lazy private var encoder = JSONEncoder()
    lazy private var decoder = JSONDecoder()
    
    init(dataSource : ServerDataSource) {
        self.dataSource = dataSource
    }
    
    func start() {
        
    }
}
