//
//  UserProvider.swift
//  SWiPE
//
//  Created by Zoe on 2022/10/31.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserProvider {
    static let shared = UserProvider()
    
    func addUser(story: String) {
        let user = Firestore.firestore().collection("Users")
        let document = user.document()
        let userData = User(
            id: document.documentID,
            name: "Zoe",
            email: "12345678@gmail.com",
            story: story
        )
    
        do {
            try user.document(document.documentID).setData(from: userData)
        } catch {
            print(error)
        }
    }
}
