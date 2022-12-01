//
//  CallVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/30.
//

import UIKit
import AgoraRtcKit

class CallVC: UIViewController, AgoraRtcEngineDelegate {
    var roomId: String?
    var receiver: User?
    var sender: User?
    var callData: Call?
    var agoraKit: AgoraRtcEngineKit?
    var messageID: String?
    var status: CallStatus? {
        didSet {
            callJudgement(status: status)
        }
    }
    
    var isSender = false

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var phoneAcceptButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var phoneRejectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCallRequest()
        setUI()
        addListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setUI() {
        if isSender {
            userImage.loadImage(receiver?.story)
            [phoneAcceptButton, phoneRejectButton].forEach { button in
                button?.isHidden = true
            }
        } else {
            userImage.loadImage(callData?.senderImage)
            endButton.isHidden = true
        }
    }
    
    private func updateIsCall() {
        guard let callData = callData else { return }
        ChatManager.shared.updateCallDocument(messageId: callData.messageId, data: ["isCall": false])
    }
    
    private func addCallRequest() {
        guard let roomId = roomId,
        let receiver = receiver,
        let sender = sender else { return }
        
        if isSender {
            ChatManager.shared.addCallRequest(
                roomId: roomId,
                sender: sender,
                receiver: receiver) { [weak self] result in
                    switch result {
                    case .success(let success):
                        self?.messageID = success
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
    
    private func addListener() {
        if isSender {
            guard let messageID = messageID else { return }
            callStatusListener(messageId: messageID)
        } else {
            guard let callData = callData else { return }
            callStatusListener(messageId: callData.messageId)
        }
    }
    
    private func callStatusListener(messageId: String) {
        ChatManager.shared.addStatusListener(messageId: messageId) { [weak self] result in
            switch result {
            case .success(let success):
                self?.status = success
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func updateStatus(messageId: String, status: [String: Bool]) {
        ChatManager.shared.updateCallStatus(messageId: messageId, data: status)
    }
    
    private func callJudgement(status: CallStatus?) {
        if let status = status {
            let hasConnect = status.senderStatus && status.receiverStatus
            let disconnected = !status.senderStatus && !status.receiverStatus
            
            if hasConnect {
                joinVoiceRoom()
            } else if disconnected {
                updateIsCall()
                dismiss(animated: true)
            }
        }
    }
    
    @IBAction func acceptCall(_ sender: Any) {
        guard let callData = callData else { return }
        [phoneAcceptButton, phoneRejectButton].forEach { button in
            button?.isHidden = true
        }
        endButton.isHidden = false
        
        updateStatus(messageId: callData.messageId, status: ["receiverStatus": true])
    }
    
    @IBAction func rejectCall(_ sender: Any) {
        guard let callData = callData else { return }

        updateStatus(messageId: callData.messageId, status: ["senderStatus": false])
    }
    
    @IBAction func endCall(_ sender: Any) {
        if isSender {
            guard let messageID = messageID else { return }
            updateStatus(messageId: messageID, status: ["senderStatus": false])
        } else {
            guard let callData = callData else { return }
            updateStatus(messageId: callData.messageId, status: ["senderStatus": false])
        }
    }
}

extension CallVC {
    private func joinVoiceRoom() {
        let profile: AgoraAudioProfile = .default
        let scenario: AgoraAudioScenario = .default
        var channelName = ""
        
        if isSender {
            guard let roomID = roomId else { return }
            channelName = roomID
        } else {
            guard let callData = callData else { return }
            channelName = callData.roomId
        }
                
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "\(JoinChannelVC.self)") as? JoinChannelVC else { return }
        
        controller.configs = [
            "channelName": channelName,
            "audioProfile": profile,
            "audioScenario": scenario
        ]
        
        AgoraManager.shared.generateToken(channelName: channelName, uid: 0) {
            self.present(controller, animated: true)
        }
    }
}
