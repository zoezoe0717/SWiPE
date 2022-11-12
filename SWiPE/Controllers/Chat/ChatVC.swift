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
    
    var friendId: [Id] = []
    var roomId: [ChatRoom] = []
    
    @IBOutlet weak var chatTableView: UITableView! {
        didSet {
            chatTableView.delegate = self
            chatTableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRoomId()
    }
    
    private func setUI() {
        view.backgroundColor = CustomColor.base.color
    }
    
    private func getRoomId() {
        self.roomId = []
        self.friendList = []
        ChatManager.shared.getChat { result in
            switch result {
            case .success(let id):
                self.roomId = id
                self.roomId.sort(by: { $0.lastUpdated > $1.lastUpdated })
                self.getFriendID(roomIds: self.roomId)

            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getFriendID(roomIds: [ChatRoom]) {
        self.friendList = []
        ChatManager.shared.getFriendData(roomIds: roomIds) { result in
            switch result {
            case .success(let friends):
                print("---C\(friends)")
                self.friendList.append(friends)
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
        if let controller = storyboard?.instantiateViewController(withIdentifier: "\(ChatRoomVC.self)") as? ChatRoomVC {
            let id = roomId[indexPath.item].id
            controller.id = id
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
