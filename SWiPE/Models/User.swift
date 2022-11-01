//
//  User.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/1.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let story: String
//    let beLike: [String]
//    let friendList: [String]
//    let chatRoom: ChatRoom
}

struct ChatRoom: Codable {
    let id: String
    let message: String
    let time: Double
    let type: String
}
