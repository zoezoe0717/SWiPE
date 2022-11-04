//
//  ChatRoomVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/3.
//

import UIKit

class ChatRoomVC: UIViewController {
    var mockMessage = Message(
        senderId: "",
        messageId: "",
        message: "Hooo",
        createdTime: 0,
        type: ""
    )
    var id = ""
    var message: [Message] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
//        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMessage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func getMessage() {
        let query = FirestoreEndpoint.messages(id).ref.order(by: "createdTime", descending: true)
        
        FireBaseManager.shared.getDocument(query: query) { [weak self] (message: [Message]) in
            guard let `self` = self else { return }
            self.message = message
            print(self.message.count)
        }
    }
    
    
    @IBAction func sendMessage(_ sender: Any) {
        ChatManager.shared.addMessage(id: id, message: &mockMessage) { result in
            switch result {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error)
            }
        }
    }
}
