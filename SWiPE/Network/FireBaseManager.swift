//
//  MatchProvide.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/1.
//

import Foundation
import FirebaseFirestore

class FireBaseManager {
    static let shared = FireBaseManager()
    
    lazy var db = Firestore.firestore()
    
    func getUser(completion: @escaping (Result<[User], Error>) -> Void) {
        db.collection("Users").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let snapshot = snapshot else { return }
                
                let user = snapshot.documents.compactMap { snapshot in
                    try? snapshot.data(as: User.self)
                }
                
                completion(.success(user))
            }
        }
    }
    
    func addUser(user: inout User, completion: @escaping (Result<String, Error>) -> Void) {
        let document = db.collection("Users").document()
        user.id = document.documentID
        user.createdTime = Date().millisecondsSince1970
        
        document.setData(user.toDict) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Success"))
            }
        }
    }
    
    func updateLocation(user: User, completion: @escaping (Result<String, Error>) -> Void) {
        let document = db.collection("Users").document(user.id)
        document.updateData(["latitude": user.latitude, "longitude": user.longitude]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success("Update Success"))
            }
        }
    }
    
    func searchUser(user: User, netizen: User, completion: @escaping (Result<String, Error>) -> Void) {
        var findID = false
        let document = db.collection("Users").document(user.id).collection("BeLiked")
        
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
        let document = db.collection("Users").document(user.id).collection("BeLiked")
        
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
    
    func addBeLike(user: User, netizen: User) {
        let document = db.collection("Users").document(netizen.id).collection("BeLiked").document(user.id)
        
        document.setData(["id": user.id]) { error in
            if let error = error {
                print(error)
            } else {
                print("Success add SubCollection")
            }
        }
    }
    
    func addFriendList(user: User, netizen: User) {
        let document = db.collection("Users").document(user.id).collection("FriendList").document(netizen.id)
        
        document.setData(["id": netizen.id]) { error in
            if let error = error {
                print(error)
            } else {
                print("Success add SubCollection")
            }
        }
    }
    
    func deleteUser(user: User, netizen: User) {
        db.collection("Users").document(user.id).collection("BeLiked").document(netizen.id).delete() { error in
            if let error = error {
                print(error)
            } else {
                print("Document successfully removed!")
            }
        }
    }
}
