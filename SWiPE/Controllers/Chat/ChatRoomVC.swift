//
//  ChatRoomVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/3.
//

import UIKit
import PhotosUI

class ChatRoomVC: UIViewController {
    @IBOutlet weak var friendLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var inputMessageBaseView: UIView!
    
    @IBOutlet weak var messageInputView: UIView!
    
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var chatRoomTableView: UITableView! {
        didSet {
            chatRoomTableView.delegate = self
            chatRoomTableView.dataSource = self
            chatRoomTableView.register(UINib(nibName: "\(OwnTextCell.self)", bundle: nil), forCellReuseIdentifier: "\(OwnTextCell.self)")
            chatRoomTableView.register(UINib(nibName: "\(FriendTextCell.self)", bundle: nil), forCellReuseIdentifier: "\(FriendTextCell.self)")
            chatRoomTableView.register(UINib(nibName: "\(OwnImageCell.self)", bundle: nil), forCellReuseIdentifier: "\(OwnImageCell.self)")
            chatRoomTableView.register(UINib(nibName: "\(FriendImageCell.self)", bundle: nil), forCellReuseIdentifier: "\(FriendImageCell.self)")
        }
    }
    
    var id = ""
    
    var messageImage: UIImage?

    var message: [Message] = [] {
        didSet {
            chatRoomTableView.reloadData()
        }
    }
    
    var friendData: User? {
        didSet {
            friendLabel.text = friendData?.name
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
        setUI()
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
    
    private func setUI() {
        messageInputView.layer.cornerRadius = messageInputView.bounds.width * 0.06
        
        chatRoomTableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        chatRoomTableView.layer.cornerRadius = 50
        
        inputMessageBaseView.backgroundColor = CustomColor.main.color
        
        backButton.tintColor = CustomColor.main.color
    }
    
    private func getMessage() {
        let query = FirestoreEndpoint.chatRoomsMessages(id).ref.order(by: "createdTime", descending: true)
        
        FireBaseManager.shared.getDocument(query: query) { [weak self] (message: [Message]) in
            guard let `self` = self else { return }
            self.message = message
        }
    }
    
    private func pushMessage(message: inout Message) {
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
    
    private func sendImageMessage() {
        guard let messageImage = messageImage else { return }
        ChatManager.shared.addImageMessage(id: id, image: messageImage) { result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func backChatPage(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        var mockMessage = Message(
            senderId: "",
            messageId: "",
            message: "",
            createdTime: 0,
            type: MessageType.text.rawValue
        )
        
        if let text = messageTextView.text {
            if text.isEmpty {
                print("輸入為空")
            } else {
                mockMessage.message = text
                pushMessage(message: &mockMessage)
            }
        }
    
        messageTextView.text = nil
    }
    
    @IBAction func openAlbum(_ sender: Any) {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .any(of: [.images, .videos])
        configuration.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
}

extension ChatRoomVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var messageCell = UITableViewCell()
        let isUser = message[indexPath.item].senderId == ChatManager.mockId
        let isText = message[indexPath.item].type == MessageType.text.rawValue

        if isUser {
            if isText {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(OwnTextCell.self)", for: indexPath) as? OwnTextCell else {
                    fatalError("DEBUG: Can not create OwnTextCell")
                }
                cell.setText(message: message[indexPath.item])
                cell.userImage.loadImage(userData?.story)
                messageCell = cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(OwnImageCell.self)", for: indexPath) as? OwnImageCell else {
                    fatalError("DEBUG: Can not create OwnTextCell")
                }
                cell.setup(message: message[indexPath.item])
                cell.userImage.loadImage(userData?.story)
                messageCell = cell
            }
        } else {
            if isText {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(FriendTextCell.self)", for: indexPath) as? FriendTextCell else {
                    fatalError("DEBUG: Can not create FriendTextCell")
                }
                
                cell.setText(message: message[indexPath.item])
                cell.friendImageView.loadImage(friendData?.story)
                messageCell = cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(FriendImageCell.self)", for: indexPath) as? FriendImageCell else {
                    fatalError("DEBUG: Can not create FriendTextCell")
                }
                
                cell.setup(message: message[indexPath.item])
                cell.userImage.loadImage(friendData?.story)
                messageCell = cell
            }
        }
        
        return messageCell
    }
}

extension ChatRoomVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        let provider = result.itemProvider
        
        if provider.canLoadObject(ofClass: UIImage.self) {
            self.dealWithImage(result)
        } else if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            self.dealWithVideo(result)
        }
    }
    
    private func dealWithImage(_ result: PHPickerResult) {
        let provider = result.itemProvider
        provider.loadObject(ofClass: UIImage.self) { image, _ in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self.messageImage = image
                    self.sendImageMessage()
                }
            }
        }
    }
    
    private func dealWithVideo(_ result: PHPickerResult) {
        let movie = UTType.movie.identifier
        let provider = result.itemProvider
        
        provider.loadFileRepresentation(forTypeIdentifier: movie) { url, error in
            if let error = error {
                print(error)
            } else {
                guard let url = url as? NSURL else { return }
                print("===\(url)")
            }
        }
    }
}
