//
//  ChatRoomVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/3.
//

import UIKit
import Alamofire
import PhotosUI

protocol CellConfiguraable: UITableViewCell {
    func setup(message: Message, userData: User)
}

protocol RowViewModel {}

class ChatRoomVC: UIViewController {
    @IBOutlet weak var friendLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var inputMessageBaseView: UIView!
    
    @IBOutlet weak var messageInputView: UIView!
    
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var chatRoomTableView: UITableView!
    
    @IBOutlet weak var moreOptionsButton: UIButton!
    
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
    
    var callData: Call?
    
    var isFriendAngry: Bool?
    var isUserAngry: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        setUI()
        addListener()
        chatRoomTableView.transform = CGAffineTransform(rotationAngle: .pi)
        setTableView()
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
    
    private func setTableView() {
        chatRoomTableView.delegate = self
        chatRoomTableView.dataSource = self
        
        [
            OwnTextCell.identifier,
            FriendTextCell.identifier,
            OwnImageCell.identifier,
            FriendImageCell.identifier,
            OwnCallCell.identifier,
            FriendCallCell.identifier
        ].forEach { chatRoomTableView.zRegisterCellWithNib(identifier: $0, bundle: nil) }
    }
    
    private func setUI() {
        messageInputView.layer.cornerRadius = messageInputView.bounds.width * 0.06
        
        chatRoomTableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        chatRoomTableView.layer.cornerRadius = 50
        chatRoomTableView.backgroundColor = CustomColor.base.color
        
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
        ChatManager.shared.addListener(id: id) { [weak self] result in
            switch result {
            case .success(let message):
                self?.message = message
            case .failure(let error):
                print(error)
            }
        }
        
        ChatManager.shared.addAngryListener(id: id) { [weak self] result in
            switch result {
            case .success(let isAngry):
                if isAngry.id == UserUid.share.getUid() {
                    self?.isUserAngry = isAngry.isAngry
                } else {
                    self?.isFriendAngry = isAngry.isAngry
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getMemberData(id: String) {
        ChatManager.shared.getMember(roomId: id) { member in
            if member.id == UserUid.share.getUid() {
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
        
        guard let text = messageTextView.text else { return }
        
        if text.isEmpty {
            print("輸入為空")
        } else {
            mockMessage.message = text
            pushMessage(message: &mockMessage)
        }
        
        if let isFriendAngry = isFriendAngry {
            if isFriendAngry {
                ZAlertView().alert.showWarning("此用戶正在生氣中", subTitle: "寶寶生氣但寶寶不說")
            }
        }
    
        messageTextView.text = nil
    }
    
    @IBAction func chooseMoreOptions(_ sender: Any) {
        moreOptionsButton.showsMenuAsPrimaryAction = true
        moreOptionsButton.menu =
        UIMenu(children: [
            UIAction(title: "一鍵生氣", image: UIImage(named: "angry")) { _ in
                self.angryClick()
            },
            UIAction(title: "封鎖用戶", image: UIImage(named: "block")) { _ in
                self.block()
            }
        ])
    }
    
    private func angryClick() {
        guard let isUserAngry = isUserAngry else { return }

        if !isUserAngry {
            let message = AlertMessage(alertTitle: "很生氣？", alertSubTitle: "確定要讓對方感受您的憤怒嗎", isAngry: true)
            ZAlertView.shared.angryView(message: message, roomID: id)
        } else {
            let message = AlertMessage(alertTitle: "氣消了？", alertSubTitle: "您已經消氣了嗎？", isAngry: false)

            ZAlertView.shared.angryView(message: message, roomID: id)
        }
    }
    
    private func block() {
        let message = AlertMessage(alertTitle: "封鎖確認", alertSubTitle: "封鎖後將看不到此聊天室\r如需解封鎖請在設定頁面修改")
        
        ZAlertView.shared.blockView(message: message, roomID: id)
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
    
    @IBAction func voiceCall(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Call", bundle: nil)
        
        if let controller = storyboard.instantiateViewController(withIdentifier: "\(CallVC.self)") as? CallVC {
            controller.roomId = id
            controller.receiver = friendData
            controller.sender = userData
            controller.isSender = true
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: false)
        }
    }
}

extension ChatRoomVC {
    func removeAccount(params: [String: String]) {
        let token = UserUid.share.keychain.get("refreshToken")
        
        let headers: HTTPHeaders = ["content-type": "application/x-www-form-urlencoded"]

        AF.request("https://appleid.apple.com/auth/revoke", method: .post, parameters: params, headers: headers).response { response in
            if response.response?.statusCode == 200 {
                print("SUCCESS!")
            }
        }
    }
}

extension ChatRoomVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var messageCell = UITableViewCell()
        var messageType = MessageType.text
        let message = message[indexPath.item]
        let sender = message.senderId == UserUid.share.getUid() ? MessageSender.isFromUser : MessageSender.isFromFriend
        let snderImage = message.senderId == UserUid.share.getUid() ? userData : friendData
        let isText = message.type == MessageType.text.rawValue
        let isImage = message.type == MessageType.image.rawValue
        
        if isText {
            messageType = .text
        } else if isImage {
            messageType = .image
        } else {
            messageType = .call
        }
        
        let identifier = getCellIdentifier(sender: sender, type: messageType)

        if
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? CellConfiguraable,
            let snderImage = snderImage
        {
            cell.setup(message: message, userData: snderImage)
            messageCell = cell
        }
        return messageCell
    }
    
    private func getCellIdentifier(sender: MessageSender, type: MessageType) -> String {
        switch (sender, type) {
        case (.isFromUser, .text):
            return OwnTextCell.identifier
            
        case (.isFromUser, .image):
            return OwnImageCell.identifier
            
        case (.isFromUser, .call):
            return OwnCallCell.identifier
            
        case (.isFromFriend, .text):
            return FriendTextCell.identifier
            
        case (.isFromFriend, .image):
            return FriendImageCell.identifier
            
        case (.isFromFriend, .call):
            return FriendCallCell.identifier
        }
    }
}

extension ChatRoomVC: PHPickerViewControllerDelegate {
    internal func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
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
            }
        }
    }
}
