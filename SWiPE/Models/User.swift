//
//  User.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/1.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable {
    var id: String
    var name: String
    var email: String
    var latitude: Double
    var longitude: Double
    var age: Int
    var story: String
    var createdTime: Int64
    var index: Int
    
    var toDict: [String: Any] {
        return [
            "id": id as Any,
            "name": name as Any,
            "email": email as Any,
            "latitude": latitude as Any,
            "longitude": latitude as Any,
            "age": age as Any,
            "story": story as Any,
            "createdTime": createdTime as Any,
            "index": index as Any
        ]
    }
}

struct FriendListID: Codable {
    let id: String
}
