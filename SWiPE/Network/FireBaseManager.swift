//
//  MatchProvide.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/1.
//

import Foundation
import FirebaseFirestore

enum FirestoreEndpoint {
    case users
    
    case usersChatRoomID(String)
    
    case usersBeLiked(String)
    
    case usersFriendList(String)
    
    case chatRooms
    
    case chatRoomsMessages(String)
    
    case chatRoomsMembers(String)

    var ref: CollectionReference {
        let firestore = Firestore.firestore()
        switch self {
        case .users:
            return firestore.collection("Users")
            
        case .usersChatRoomID(let id):
            return firestore.collection("Users").document(id).collection("ChatRoomID")
            
        case .usersBeLiked(let id):
            return firestore.collection("Users").document(id).collection("BeLiked")
            
        case .usersFriendList(let id):
            return firestore.collection("Users").document(id).collection("FriendList")
            
        case .chatRooms:
            return firestore.collection("ChatRoom")
            
        case .chatRoomsMessages(let id):
            return firestore.collection("ChatRoom").document(id).collection("Message")
            
        case .chatRoomsMembers(let id):
            return firestore.collection("ChatRoom").document(id).collection("Members")
        }
    }
}

class FireBaseManager {
    static let shared = FireBaseManager()
        
    private func parseDocument<T: Decodable>(snapshot: QuerySnapshot?, error: Error?) -> [T] {
        guard let snapshot = snapshot else {
            let error = error?.localizedDescription ?? ""
            print("DEBUG: \(error)")
            return []
        }
        
        var models: [T] = []
        snapshot.documents.forEach { document in
            do {
                let item = try document.data(as: T.self)
                models.append(item)
            } catch {
                print("DEBUG: Error decoding \(T.self)")
            }
        }
        return models
    }
        
    func getDocument<T: Decodable>(query: Query, completion: @escaping ([T]) -> Void) {
        query.getDocuments { [weak self] snapshot, error in
            guard let `self` = self else { return }
            completion(self.parseDocument(snapshot: snapshot, error: error))
        }
    }
    
    func getUser(completion: @escaping (Result<User?, Error>) -> Void ) {
        let document = FirestoreEndpoint.users.ref.document(ChatManager.mockId)
        document.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                let user = try? snapshot.data(as: User.self)
                completion(.success(user))
            }
        }
    }
    
    func updateLocation(user: User, completion: @escaping (Result<String, Error>) -> Void) {
        let document = FirestoreEndpoint.users.ref.document(user.id)
        document.updateData(["latitude": user.latitude, "longitude": user.longitude]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Update Success"))
            }
        }
    }
    
//    func updateStory(user: User) {
//        let document = FirestoreEndpoint.users.ref.document(user.id)
//        document.updateData(["story": user.story]) { error in
//            if let error = error {
//                print(error)
//            } else {
//                print("Update Success")
//            }
//        }
//    }
    
    func updateUserData(user: User, data: [String: String]) {
        let document = FirestoreEndpoint.users.ref.document(user.id)
        document.updateData(data) { error in
            if let error = error {
                print(error)
            } else {
                print("Update Success")
            }
        }
    }
    
    func searchUser(user: User, netizen: User, completion: @escaping (Result<String, Error>) -> Void) {
        var findID = false
        let document = FirestoreEndpoint.usersBeLiked(user.id).ref
        
        document.whereField("id", isEqualTo: netizen.id).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                for _ in snapshot.documents {
                    findID = true
                }
                completion(.success("Search Success"))
                if findID {
                    self.addFriendList(user: user, netizen: netizen)
                    self.addFriendList(user: netizen, netizen: user)
                    self.deleteUser(user: user, netizen: netizen)
                    
                    ChatManager.shared.addChatRoom(user: user, netizen: netizen) { result in
                        switch result {
                        case .success(let success):
                            print(success)
                        case .failure(let error):
                            print(error)
                        }
                    }
                } else {
                    self.addBeLike(user: user, netizen: netizen)
                }
            }
        }
    }
    
    func searchBeLike(user: User, netizen: User, completion: @escaping (Result<String, Error>) -> Void) {
        let document = FirestoreEndpoint.usersBeLiked(user.id).ref
        
        document.whereField("id", isEqualTo: netizen.id).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                for _ in snapshot.documents {
                    self.deleteUser(user: user, netizen: netizen)
                }
                completion(.success("Search Success"))
            }
        }
    }
    
    func addUser(user: inout User, completion: @escaping (Result<String, Error>) -> Void) {
        let document = FirestoreEndpoint.users.ref.document()
        user.id = document.documentID
        user.createdTime = Date().millisecondsSince1970
        
        document.setData(user.toDict) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Success add user"))
            }
        }
    }
    
    func addBeLike(user: User, netizen: User) {
        let document = FirestoreEndpoint.usersBeLiked(netizen.id).ref.document(user.id)
        
        document.setData(["id": user.id]) { error in
            if let error = error {
                print(error)
            } else {
                print("Success add SubCollection")
            }
        }
    }
    
    func addFriendList(user: User, netizen: User) {
        let document = FirestoreEndpoint.usersFriendList(user.id).ref.document(netizen.id)
        
        document.setData(["id": netizen.id]) { error in
            if let error = error {
                print(error)
            } else {
                print("Success add SubCollection")
            }
        }
    }
    
    func deleteUser(user: User, netizen: User) {
        let document = FirestoreEndpoint.usersBeLiked(user.id).ref.document(netizen.id)
        document.delete { error in
            if let error = error {
                print(error)
            } else {
                print("Document successfully removed!")
            }
        }
    }
}
