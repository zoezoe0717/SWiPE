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
    
    static let mockId = "FVaDDQXL8EIjC05tuwAT"
    
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
        
        document.collection("Members").getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            snapshot.documents.compactMap { member in
                guard let memberId = try? member.data(as: FriendID.self) else { return }
                
                FirestoreEndpoint.users.ref.document(memberId.id).collection("ChatRoomID").document(id).updateData(["lastUpdated": Date().millisecondsSince1970]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success("Success add chatroomID"))
                    }
                }
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
            chatRoomID.document(document.documentID).setData(["id": document.documentID, "lastUpdated": Date().millisecondsSince1970]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success("Success add chatroomID"))
                }
            }
        }
    }
    
    func getChat(completion: @escaping (Result<([User], [ChatRoomID]), Error>) -> Void) {
        var friendDatas: [User] = []
        var chatRoomIds: [ChatRoomID] = []
        
        let document = FirestoreEndpoint.users.ref.document(ChatManager.mockId).collection("ChatRoomID")
        document.order(by: "lastUpdated", descending: true).getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            
            snapshot.documents.compactMap { roomId in
                guard let room = try? roomId.data(as: ChatRoomID.self) else { return }
                chatRoomIds.append(room)
                FirestoreEndpoint.chatRooms.ref.document(room.id).collection("Members").whereField("id", isNotEqualTo: ChatManager.mockId).getDocuments { snapshot, _ in
                    guard let snapshot = snapshot else { return }
                    snapshot.documents.compactMap { friendId in
                        guard let friend = try? friendId.data(as: FriendID.self) else { return }
                        FirestoreEndpoint.users.ref.document(friend.id).getDocument { snapshot, _ in
                            guard let snapshot = snapshot else { return }
                            guard let friendData = try? snapshot.data(as: User.self) else { return }
                            friendDatas.append(friendData)
                            completion(.success(([friendData], [room])))
                        }
                    }
                }
            }
        }
    }
}
