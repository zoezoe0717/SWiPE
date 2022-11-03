//
//  Chat.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/3.
//

import Foundation

struct ChatRoom: Codable {
    var lastUpdated: Double
}

struct Message: Codable {
    let senderId: String
    let messageId: String
    let message: String
    let time: Double
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case senderId = "sender_id"
        case messageId = "message_id"
        case message
        case time
        case type
    }
}

struct ChatRoomID: Codable {
    let id: String
}
