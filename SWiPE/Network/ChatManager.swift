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
    case image = "image_message"
    case video = "video_message"
}

class ChatManager {
    static let shared = ChatManager()

    func addListener(id: String, completion: @escaping(Result<[Message], Error>) -> Void) {
        let document = FirestoreEndpoint.chatRoomsMessages(id).ref.order(by: "createdTime", descending: true)
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
        let document = FirestoreEndpoint.chatRoomsMessages(id).ref.document()
        message.senderId = UserUid.share.getUid()
        message.messageId = document.documentID
        message.createdTime = Date().millisecondsSince1970
        
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
    
    func addImageMessage(id: String, image: UIImage, completion: @escaping ((Result<String, Error>) -> Void)) {
        var message = Message(
            senderId: "",
            messageId: "",
            message: "",
            createdTime: 0,
            type: MessageType.image.rawValue
        )
        
        UploadStoryProvider.shared.uploadPhoto(image: image) { [weak self] result in
            switch result {
            case .success(let url):
                message.message = "\(url)"
                
                self?.addMessage(id: id, message: &message) { result in
                    switch result {
                    case .success(let string):
                        completion(.success(string))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                
            case .failure(let error):
                print(error)
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
            
            let chatRoomID = FirestoreEndpoint.usersChatRoomID(id).ref
            chatRoomID.document(document.documentID).setData(["id": document.documentID]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success("Success add chatroomID"))
                }
            }
        }
    }
    
    func getMember(roomId: String, completion: @escaping(User) -> Void) {
        FirestoreEndpoint.chatRoomsMembers(roomId).ref.getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            let memberId = snapshot.documents.compactMap({ try? $0.data(as: Id.self) })

            memberId.forEach { member in
                FirestoreEndpoint.users.ref.document(member.id).getDocument { snapshot, _ in
                    guard let snapshot = snapshot else { return }
                    guard let memberData = try? snapshot.data(as: User.self) else { return }
                    if memberData.id == UserUid.share.getUid() {
                        completion(memberData)
                    } else {
                        completion(memberData)
                    }
                }
            }
        }
    }
    
    func getFriendData(roomIds: [ChatRoom], completion: @escaping (Result<User, Error>) -> Void) {
        let queue = DispatchQueue(label: "queue", qos: .background, attributes: .concurrent)
        let semaphore = DispatchSemaphore(value: 1)
        roomIds.forEach { room in
            queue.async {
                semaphore.wait()
                let query = FirestoreEndpoint.chatRoomsMembers(room.id).ref.whereField("id", isNotEqualTo: UserUid.share.getUid())
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
                    semaphore.signal()
                }
            }
        }
    }
    
    func getChat(completion: @escaping (Result<[ChatRoom], Error>) -> Void) {
        var roomDatas: [ChatRoom] = []
        let document = FirestoreEndpoint.usersChatRoomID(UserUid.share.getUid()).ref
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
}
