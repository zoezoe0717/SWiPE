//
//  ChatManager.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/3.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

enum MessageType: String {
    case text = "text_message"
}

class ChatManager {
    static let shared = ChatManager()
    
    lazy var db = Firestore.firestore()
    
    static let mockId = AddDataVC.newUser.id
    
    func getMember(roomId: String, completion: @escaping(User) -> Void) {
        FirestoreEndpoint.chatRooms.ref.document(roomId).collection("Members").getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            let memberId = snapshot.documents.compactMap({ try? $0.data(as: Id.self) })

            memberId.forEach { member in
                FirestoreEndpoint.users.ref.document(member.id).getDocument { snapshot, error in
                    guard let snapshot = snapshot else { return }
                    guard let memberData = try? snapshot.data(as: User.self) else { return }
                    if memberData.id == ChatManager.mockId {
                        completion(memberData)
                    } else {
                        completion(memberData)
                    }
                }
            }
        }
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
    
    func getFriendData(roomIds: [ChatRoom], completion: @escaping (Result<User, Error>) -> Void) {
        roomIds.forEach { room in
            let query = FirestoreEndpoint.chatRooms.ref.document(room.id).collection("Members").whereField("id", isNotEqualTo: ChatManager.mockId)
            query.getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    guard let snapshot = snapshot else { return }
                    snapshot.documents.forEach { friendId in
                        guard let friendId = try? friendId.data(as: Id.self) else { return }
                        FirestoreEndpoint.users.ref.document(friendId.id).getDocument { snapshot, _ in
                            guard let snapshot = snapshot else { return }
                            guard let friendData = try? snapshot.data(as: User.self) else { return }
                            completion(.success(friendData))
                        }
                    }
                }
            }
        }
    }
    
    func getChat(completion: @escaping (Result<[ChatRoom], Error>) -> Void) {
        var roomDatas: [ChatRoom] = []
        let document = FirestoreEndpoint.users.ref.document(ChatManager.mockId).collection("ChatRoomID")
        
        document.getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            let count = snapshot.count
            snapshot.documents.forEach { roomId in
                guard let room = try? roomId.data(as: Id.self) else { return }
                FirestoreEndpoint.chatRooms.ref.document(room.id).getDocument { snapshot, _ in
                    guard let snapshot = snapshot else { return }
                    guard let room = try? snapshot.data(as: ChatRoom.self) else { return }
                    roomDatas.append(room)
                    if roomDatas.count == count {
                        completion(.success(roomDatas))
                    }
                }
            }
        }
    }
}
