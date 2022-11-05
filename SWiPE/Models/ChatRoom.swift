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
    var senderId: String
    var messageId: String
    var message: String
    var createdTime: Int64
    var type: String
    
//    enum CodingKeys: String, CodingKey {
//        case senderId = "sender_id"
//        case messageId = "message_id"
//        case message
//        case createdTime
//        case type
//    }
    
    var toDict: [String: Any] {
        return [
            "senderId": senderId as Any,
            "messageId": messageId as Any,
            "message": message as Any,
            "createdTime": createdTime as Any,
            "type": type as Any
        ]
    }
}

struct ChatRoomID: Codable {
    let id: String
}

struct FriendID: Codable {
    let id: String
}
