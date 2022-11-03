//
//  ChatVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/3.
//

import UIKit

class ChatVC: UIViewController {
    var friendList: [User] = [] {
        didSet {
            chatTableView.reloadData()
        }
    }
    
    var roomId: [ChatRoomID] = []
    
    @IBOutlet weak var chatTableView: UITableView! {
        didSet {
            chatTableView.delegate = self
            chatTableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFriendList()
    }
    
    private func getFriendList() {
        ChatManager.shared.getChatRoom { result in
            switch result {
            case let .success((friend, roomId)):
                self.friendList = friend
                self.roomId = roomId
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(ChatCell.self)", for: indexPath) as? ChatCell else {
            fatalError("DEBUG: Can not create ChatCell")
        }
        
        cell.setUI(friend: friendList[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(friendList[indexPath.item].id)")
        print("\(roomId[indexPath.item].id)")
    }
}
