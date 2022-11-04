//
//  ChatManager.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/3.
//

import Foundation
import FirebaseFirestore

enum MessageType: String {
    case text = "text_message"
}

class ChatManager {
    static let shared = ChatManager()
    
    lazy var db = Firestore.firestore()
    
    static let mockId = "L3gBeb91hnXjvUOKF4Gz"
    
    func getMember(roomId: String) {
    }
    
    func addListener(id: String, completion: @escaping(Result<[Message], Error>) -> Void) {
        let document = FirestoreEndpoint.messages(id).ref.order(by: "createdTime", descending: true)
        document.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                
                let message = snapshot.documents.compactMap { snapshot in
                    try? snapshot.data(as: Message.self)
                }
                completion(.success(message))
            }
        }
    }
    
    func addMessage(id: String, message: inout Message, completion: @escaping (Result<String, Error>) -> Void) {
        let document = FirestoreEndpoint.messages(id).ref.document()
        message.senderId = ChatManager.mockId
        message.messageId = document.documentID
        message.createdTime = Date().millisecondsSince1970
        message.type = MessageType.text.rawValue
        
        document.setData(message.toDict) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Success add message"))
                self.updateData(id: id) { result in
                    switch result {
                    case .success(let success):
                        print(success)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    private func updateData(id: String, completion: @escaping(Result<String, Error>) -> Void) {
        let document = FirestoreEndpoint.chatRooms.ref.document(id)
        document.updateData(["lastUpdated": Date().millisecondsSince1970]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Success: updated lastUpdated"))
            }
        }
    }
    
    func addChatRoom(user: User, netizen: User, completion: @escaping (Result<String, Error>) -> Void) {
        let document = FirestoreEndpoint.chatRooms.ref.document()
        document.setData(["lastUpdated": Date().millisecondsSince1970, "id": document.documentID]) { error in
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
    
    func getChat(completion: @escaping (Result<([User], [ChatRoomID]), Error>) -> Void) {
        var chatId: [ChatRoomID] = []
        var friendData: [User] = []
        
        db.collection("Users").document(ChatManager.mockId).collection("ChatRoomID").getDocuments { snapshot, error in
            if let error = error {
                print(error)
            } else {
                guard let snapshot = snapshot else { return }
                let chatRoomID = snapshot.documents.compactMap { try? $0.data(as: ChatRoomID.self) }
                chatId.append(contentsOf: chatRoomID)
                
                chatRoomID.forEach { room in
                    self.db.collection("ChatRoom").order(by: "lastUpdated", descending: true).whereField("id", isEqualTo: room.id).getDocuments { snapshot, error in
                        if let error = error {
                            print(error)
                        } else {
                            guard let snapshot = snapshot else { return }
                            let chatRoomId = snapshot.documents.compactMap { try? $0.data(as: ChatRoomID.self) }
                            chatId.append(contentsOf: chatRoomId)
                        }
                    }
                    self.db.collection("ChatRoom")
                        .document(room.id)
                        .collection("Members")
                        .whereField("id", isNotEqualTo: ChatManager.mockId)
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
}
