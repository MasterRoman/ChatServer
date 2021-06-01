//
//  MessageModel.swift
//  CourseworkChat
//
//  Created by Admin on 20.05.2021.
//

import Foundation

struct Sender : SenderType,Codable{
    var senderId: String
    var displayName: String
}

extension MessageKind : Codable{
    enum CodingKeys: CodingKey {
        case text, attributedText, photo, video,location,emoji,audio,contact,linkPreview,custom
    }
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keys = container.allKeys.first
        
        switch keys {
        case .text:
            let text = try container.decode(String.self,forKey: .text)
            self = .text(text)
        default:
            self = .custom(String("noValue"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode(text, forKey: .text)
        //        case .attributedText(let attributedText):
        //            try container.encode(attributedText, forKey: .attributedText)
        //        case .photo(let photo):
        //            try container.encode(photo, forKey: .photo)
        //        case .video(_):
        //            <#code#>
        //        case .location(_):
        //            <#code#>
        //        case .emoji(_):
        //            <#code#>
        //        case .audio(_):
        //            <#code#>
        //        case .contact(_):
        //            <#code#>
        //        case .linkPreview(_):
        //            <#code#>
        //        case .custom(_):
        //            <#code#>
        default:
            return
        }
        
    }
}

extension MessageKind{
    func getValue() -> String{
        switch self {
        case .text(let text):
            return text
        default:
            return "Data"
        }
    }
}

struct Message : MessageType,Codable {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(sender: SenderType, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
    
    enum CodingKeys: String, CodingKey {
        case sender
        case messageId
        case sentDate
        case kind
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Sender(senderId: sender.senderId, displayName: sender.displayName), forKey: .sender)
        try container.encode(messageId, forKey: .messageId)
        try container.encode(sentDate, forKey: .sentDate)
        try container.encode(kind, forKey: .kind)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.sender = try container.decode(Sender.self, forKey: .sender)
        self.messageId = try container.decode(String.self, forKey: .messageId)
        self.sentDate = try container.decode(Date.self, forKey: .sentDate)
        self.kind = try container.decode(MessageKind.self, forKey: .kind)
        
    }
}
