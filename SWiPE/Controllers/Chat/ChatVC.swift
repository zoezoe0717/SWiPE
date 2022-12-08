//
//  ChatVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/3.
//

import UIKit

class ChatVC: UIViewController {
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleBackgroundView: UIView!
    
    var friendList: [User] = [] {
        didSet {
            chatTableView.reloadData()
            print("===A\(friendList)")
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
        
        placeholderLabel.isHidden = true
        
        titleBackgroundView.backgroundColor = CustomColor.main.color
        titleLabel.text = Constants.ChatVCString.title
        
        chatTableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        chatTableView.layer.cornerRadius = 50
    }
    
    private func getRoomId() {
        self.roomId = []
        self.friendList = []
        ChatManager.shared.getChat { [weak self] result in
            guard let self = self else { return }
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
        ProgressHUD.show()
        ChatManager.shared.getFriendData(roomIds: roomIds) { [weak self] result in
            switch result {
            case .success(let friends):
                self?.friendList = friends
                ProgressHUD.dismiss()
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
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
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        }
    }
}
