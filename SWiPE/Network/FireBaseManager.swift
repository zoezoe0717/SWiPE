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
                guard let snapshot = snapshot else {
                    return
                }
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
}
