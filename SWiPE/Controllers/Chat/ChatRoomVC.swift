//
//  ChatRoomVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/3.
//

import UIKit

class ChatRoomVC: UIViewController {
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var chatRoomTableView: UITableView! {
        didSet {
            chatRoomTableView.delegate = self
            chatRoomTableView.dataSource = self
            chatRoomTableView.register(UINib(nibName: "\(OwnTextCell.self)", bundle: nil), forCellReuseIdentifier: "\(OwnTextCell.self)")
            chatRoomTableView.register(UINib(nibName: "\(FriendTextCell.self)", bundle: nil), forCellReuseIdentifier: "\(FriendTextCell.self)")
        }
    }
    
    var id = ""
    var message: [Message] = [] {
        didSet {
            chatRoomTableView.reloadData()
        }
    }
    
    var friendData: User? {
        didSet {
            chatRoomTableView.reloadData()
        }
    }
    var userData: User? {
        didSet {
            chatRoomTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        addListener()
        chatRoomTableView.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMessage()
        getMemberData(id: id)
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
        }
    }
    
    private func pushMessage( message: inout Message) {
        ChatManager.shared.addMessage(id: id, message: &message) { result in
            switch result {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func addListener() {
        ChatManager.shared.addListener(id: id) { result in
            switch result {
            case .success(let message):
                self.message = message
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getMemberData(id: String) {
        ChatManager.shared.getMember(roomId: id) { member in
            if member.id == ChatManager.mockId {
                self.userData = member
            } else {
                self.friendData = member
            }
        }
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        var mockMessage = Message(
            senderId: "",
            messageId: "",
            message: "",
            createdTime: 0,
            type: ""
        )
        
        if let text = messageTextField.text {
            if text.isEmpty {
                print("輸入為空")
            } else {
                mockMessage.message = text
                pushMessage(message: &mockMessage)
            }
        }
        
        messageTextField.text = nil
    }
}

extension ChatRoomVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var messageCell = UITableViewCell()
        if message[indexPath.item].senderId == ChatManager.mockId {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(OwnTextCell.self)", for: indexPath) as? OwnTextCell else {
                fatalError("DEBUG: Can not create OwnTextCell")
            }
            cell.setText(message: message[indexPath.item])
            cell.userImage.loadImage(userData?.story)
            messageCell = cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(FriendTextCell.self)", for: indexPath) as? FriendTextCell else {
                fatalError("DEBUG: Can not create OwnTextCell")
            }
            
            cell.setText(message: message[indexPath.item])
            cell.friendImageView.loadImage(friendData?.story)
            messageCell = cell
        }
        
        return messageCell
    }
}
