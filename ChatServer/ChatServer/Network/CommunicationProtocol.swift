//
//  CommunicationProtocol.swift
//  CourseworkChat
//
//  Created by Admin on 22.05.2021.
//

import Foundation

enum SendReceiveProtocol : Codable{
    enum CodingKeys: CodingKey {
        case checkLogin,registration,authorization,newChat,newMessage,newContact,offline
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keys = container.allKeys.first
        switch keys {
        case .checkLogin:
            let login = try container.decode(String.self, forKey: .checkLogin)
            self = .checkLogin(login: login)
        case .registration:
            let credentials = try container.decode(Credentials.self, forKey: .registration)
            self = .registration(credentials: credentials)
        case .authorization:
            let credentials = try container.decode(Credentials.self, forKey: .authorization)
            self = .authorization(credentials: credentials)
        case .newChat:
            let chat = try container.decode(Chat.self, forKey: .newChat)
            self = .newChat(chat: chat)
        case .newMessage:
            let message = try container.decode(ChatBody.self, forKey: .newMessage)
            self = .newMessage(message: message)
        case .newContact:
            var nestedContainer = try container.nestedUnkeyedContainer(forKey: .newContact)
            let login = try nestedContainer.decode(String.self)
            let contact = try nestedContainer.decode(Contact?.self)
            self = .newContact(login: login, contact: contact)
        case .offline:
            let login = try container.decode(String.self, forKey: .offline)
            self = .offline(login: login)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum."
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .checkLogin(login: let login):
            try container.encode(login, forKey: .checkLogin)
        case .registration(credentials : let  credentials):
            try container.encode(credentials, forKey: .registration)
        case .authorization(credentials : let  credentials):
            try container.encode(credentials, forKey: .authorization)
        case .newChat(chat: let chat):
            try container.encode(chat, forKey: .newChat)
        case .newMessage(message: let message):
            try container.encode(message, forKey: .newMessage)
        case .newContact(login: let login, contact: let contact):
            var nestedContainer = container.nestedUnkeyedContainer(forKey: .newContact)
            try nestedContainer.encode(login)
            try nestedContainer.encode(contact)
        case .offline(login: let login):
            try container.encode(login, forKey: .offline)
        
        }
    }
    
    case checkLogin(login:String)
    case registration(credentials : Credentials)
    case authorization(credentials : Credentials)
    case newChat(chat:Chat)
    case newMessage(message:ChatBody)
    case newContact(login:String,contact : Contact?)
    case offline(login:String)
    
}
