//
//  ChatManager.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/3.
//

import Foundation
import FirebaseFirestore

class ChatManager {
    static let shared = ChatManager()
    
    lazy var db = Firestore.firestore()
    let markID = "2C43U55qfP8l0x4lPUCl"
    
    func getFriendList(completion: @escaping (Result<[User], Error>) -> Void) {
        db.collection("Users").document(markID).collection("FriendList").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                
                let friendList = snapshot.documents.compactMap { snapshot in
                    try? snapshot.data(as: FriendListID.self)
                }
                
                friendList.forEach { friend in
                    self.db.collection("Users").whereField("id", isEqualTo: friend.id).getDocuments { snapshot, error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            guard let snapshot = snapshot else { return }
                            let friend = snapshot.documents.compactMap { snapshot in
                                try? snapshot.data(as: User.self)
                            }
                            completion(.success(friend))
                        }
                    }
                }
            }
        }
    }
    
    func getChatRoom(completion: @escaping (Result<([User], [ChatRoomID]), Error>) -> Void) {
        var chatId: [ChatRoomID] = []
        var friendData: [User] = []

        db.collection("Users").document("2C43U55qfP8l0x4lPUCl").collection("ChatRoomID").getDocuments { snapshot, error in
            if let error = error {
                print(error)
            } else {
                guard let snapshot = snapshot else { return }
                let chatRoomID = snapshot.documents.compactMap { try? $0.data(as: ChatRoomID.self) }
                chatId.append(contentsOf: chatRoomID)
                chatRoomID.forEach { room in
                    self.db.collection("ChatRoom")
                        .document(room.id)
                        .collection("Members")
                        .whereField("id", isNotEqualTo: self.markID)
                        .getDocuments { snapshot, error in
                        if let error = error {
                            print(error)
                        } else {
                            guard let snapshot = snapshot else { return }
                            let friendId = snapshot.documents.compactMap { try? $0.data(as: ChatRoomID.self) }
                            friendId.forEach { data in
                                self.db
                                    .collection("Users")
                                    .whereField("id", isEqualTo: data.id)
                                    .getDocuments { snapshot, error in
                                    if let error = error {
                                        completion(.failure(error))
                                    } else {
                                        guard let snapshot = snapshot else { return }
                                        let friend = snapshot.documents.compactMap { snapshot in
                                            try? snapshot.data(as: User.self)
                                        }
                                        friendData.append(contentsOf: friend)
                                        completion(.success((friendData, chatId)))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
        
        func addChatRoom(user: User, netizen: User, completion: @escaping (Result<String, Error>) -> Void) {
            let document = db.collection("ChatRoom").document()
            document.setData(["lastUpdated": Date().millisecondsSince1970]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success("Updaed time"))
                }
            }
            
            [user.id, netizen.id].forEach { id in
                document.collection("Members").document(id).setData(["id": id]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success("Success add chatroom"))
                    }
                }
                
                let chatRoomID = db.collection("Users").document(id).collection("ChatRoomID")
                chatRoomID.document(document.documentID).setData(["id": document.documentID]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success("Success add chatroomID"))
                    }
                }
            }
        }
    }
