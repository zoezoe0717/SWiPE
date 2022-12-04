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
    case call = "call_message"
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
    
    func addAngryListener(id: String, completion: @escaping(Result<ChatRoomMembers, Error>) -> Void) {
//        let member = FirestoreEndpoint.chatRoomsMembers(id).ref.whereField("id", isNotEqualTo: UserUid.share.getUid())
        let member = FirestoreEndpoint.chatRoomsMembers(id).ref
        
        member.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
                if let error = error {
                    completion(.failure(error))
                }
                return
            }
            
            snapshot.documents.forEach { snap in
                if let data = try? snap.data(as: ChatRoomMembers.self) {
                    completion(.success(data))
                }
            }
        }
    }
    
    func addCallListener(completion: @escaping(Result<[Call], Error>) -> Void) {
        let collection = FirestoreEndpoint.call.ref
        
        collection.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                let datas = snapshot.documents.compactMap { snap in
                    try? snap.data(as: Call.self)
                }
                completion(.success(datas))
            }
        }
    }
    
    func addStatusListener(messageId: String, completion: @escaping(Result<CallStatus, Error>) -> Void) {
        let collection = FirestoreEndpoint.call.ref.document(messageId).collection("Status")
        
        collection.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                snapshot.documents.forEach { snap in
                    if let data = try? snap.data(as: CallStatus.self) {
                        completion(.success(data))
                    }
                }
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
    
    func addCallMessage(callData: Call, timeMessage: String, completion: @escaping (Result<String, Error>) -> Void) {
        let document = FirestoreEndpoint.chatRoomsMessages(callData.roomId).ref.document(callData.messageId)

        let message = Message(
            senderId: callData.senderId,
            messageId: callData.messageId,
            message: timeMessage,
            createdTime: callData.createdTime,
            type: MessageType.call.rawValue
        )
        
        document.setData(message.toDict) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Success add message"))
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
        
        UploadStoryProvider.shared.uploadImageWithImgur(image: image) { [weak self] result in
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
            document.collection("Members").document(id).setData(["id": id, "isAngry": false]) { error in
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
    
    func addCallRequest(roomId: String, sender: User, receiver: User, completion: @escaping (Result<String, Error>) -> Void) {
        var callData = Call(
            messageId: "",
            senderId: sender.id,
            receiverId: receiver.id,
            roomId: roomId,
            senderImage: sender.story,
            senderName: sender.name,
            createdTime: Date().millisecondsSince1970,
            isCall: true
        )
        
        let document = FirestoreEndpoint.call.ref.document()
        callData.messageId = document.documentID
        completion(.success(document.documentID))

        document.setData(callData.toDict) { error in
            if let error = error {
                completion(.failure(error))
            }
        }
        
        let status = FirestoreEndpoint.call.ref.document(document.documentID).collection("Status")
        let callStatus = CallStatus(
            senderStatus: true,
            receiverStatus: false,
            isVideoCall: false)
        status.document(document.documentID).setData(callStatus.toDict) { error in
            if let error = error {
                completion(.failure(error))
            }
        }
    }
        
    func updateData<T>(roomID: String, data: [String: T]) {
        let document = FirestoreEndpoint.chatRoomsMembers(roomID).ref.document(UserUid.share.getUid())
        
        document.updateData(data) { error in
            if let error = error {
                print(error)
            } else {
                print("Update Success")
            }
        }
    }
    
    func updateCallStatus<T>(messageId: String, data: [String: T]) {
        let document = FirestoreEndpoint.call.ref.document(messageId).collection("Status").document(messageId)
        document.updateData(data) { error in
            if let error = error {
                print(error)
            } else {
                print("Update Success")
            }
        }
    }
    
    func updateCallDocument<T>(messageId: String, data: [String: T]) {
        let document = FirestoreEndpoint.call.ref.document(messageId)
        document.updateData(data) { error in
            if let error = error {
                print(error)
            } else {
                print("===AAAUpdate Success")
            }
        }
    }
    
    func getMember(roomId: String, completion: @escaping(User) -> Void) {
        FirestoreEndpoint.chatRoomsMembers(roomId).ref.getDocuments { snapshot, _ in
            guard let snapshot = snapshot else { return }
            let memberId = snapshot.documents.compactMap { try? $0.data(as: Id.self) }

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
    
    func blockFriend(roomID: String) {
        let document = FirestoreEndpoint.usersChatRoomID(UserUid.share.getUid()).ref.document(roomID)
    
        let blockDocument = FirestoreEndpoint.userBlock.ref
        
        document.delete()
        
        blockDocument.document(roomID).setData(["id": roomID])
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
