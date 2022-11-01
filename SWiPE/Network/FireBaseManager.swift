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
    
    func fetchUser(completion: @escaping (Result<[User], Error>) -> Void) {
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
    
    func addUser(story: String) {
        let document = db.collection("Users").document()
        let userData = User(
            id: document.documentID,
            name: "Zoe",
            email: "12345678@gmail.com",
            story: story
        )
    
        do {
            try db.collection("Users").document(document.documentID).setData(from: userData)
        } catch {
            print(error)
        }
    }
}
