//
//  Chat.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/3.
//

import Foundation

struct Message: Codable {
    var senderId: String
    var messageId: String
    var message: String
    var createdTime: Int64
    var type: String
    
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

struct Call: Codable {
    var messageId: String
    var senderId: String
    var receiverId: String
    var roomId: String
    var senderImage: String
    var senderName: String
    var createdTime: Int64
    var isCall: Bool

    var toDict: [String: Any] {
        return [
            "messageId": messageId as Any,
            "senderId": senderId as Any,
            "receiverId": receiverId as Any,
            "roomId": roomId as Any,
            "senderImage": senderImage as Any,
            "senderName": senderName as Any,
            "createdTime": createdTime as Any,
            "isCall": isCall as Any
        ]
    }
}

struct CallStatus: Codable {
    var senderStatus: Bool
    var receiverStatus: Bool
    var isVideoCall: Bool
    
    var toDict: [String: Any] {
        return [
            "senderStatus": senderStatus as Any,
            "receiverStatus": receiverStatus as Any,
            "isVideoCall": isVideoCall as Any
        ]
    }
}

struct ChatRoom: Codable {
    let id: String
    let lastUpdated: Int64
}

struct Id: Codable {
    let id: String
}

struct ChatRoomMembers: Codable {
    let id: String
    let isAngry: Bool
}
