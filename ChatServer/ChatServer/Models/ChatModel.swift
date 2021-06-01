//
//  ChatModel.swift
//  CourseworkChat
//
//  Created by Admin on 21.05.2021.
//

import Foundation

struct ChatBody : Codable {
    let chatId : UUID
    var messages : [Message]
}

class Chat : Codable{
    var senders : [Sender]
    var chatBody : ChatBody
    
    init(senders : [Sender],chatBody : ChatBody) {
        self.senders = senders
        self.chatBody = chatBody
    }
}
