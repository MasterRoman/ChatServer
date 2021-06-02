//
//  HandlerProtocol.swift
//  ChatServer
//
//  Created by Admin on 02.06.2021.
//

import Foundation
import BSDSocketWrapperMac

protocol Handler : class {
    func newChat(chat : Chat)
    func newMessage(message : ChatBody)
    func newOnline(login : String,socket : ClientEndpoint)
}
