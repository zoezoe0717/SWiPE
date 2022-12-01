//
//  CallVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/30.
//

import UIKit
import AgoraRtcKit

class CallVC: UIViewController, AgoraRtcEngineDelegate {
    var receiver: User?
    var sender: User?
    var callData: Call?
    var messageID: String?
    var roomId: String?
    var agoraKit: AgoraRtcEngineKit!
    var configs: [String: Any] = [:]
    
    var isJoined = false
    var isSender = false
    
    var status: CallStatus? {
        didSet {
            callJudgement(status: status)
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
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
        updateIsCall()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isJoined {
            agoraKit.enable(inEarMonitoring: false)
            agoraKit.disableAudio()
            agoraKit.disableVideo()
            agoraKit.leaveChannel { stats -> Void in
                print("left channel, duration: \(stats.duration)")
            }
        }
    }
    
    private func setUI() {
        if isSender {
            userImage.loadImage(receiver?.story)
            [phoneAcceptButton, phoneRejectButton].forEach { button in
                button?.isHidden = true
            }
            nameLabel.text = receiver?.name
        } else {
            userImage.loadImage(callData?.senderImage)
            endButton.isHidden = true
            nameLabel.text = callData?.senderName
        }
    }
    
    private func updateIsCall() {
        if isSender {
            guard let messageID = messageID else { return }
            ChatManager.shared.updateCallDocument(messageId: messageID, data: ["isCall": false])
        } else {
            guard let callData = callData else { return }
            ChatManager.shared.updateCallDocument(messageId: callData.messageId, data: ["isCall": false])
        }
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
    
    private func updateAllStatus(messageId: String) {
        if isJoined {
            updateStatus(messageId: messageId, status: ["senderStatus": false])
            updateStatus(messageId: messageId, status: ["receiverStatus": false])
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
            updateAllStatus(messageId: messageID)
        } else {
            guard let callData = callData else { return }
            updateStatus(messageId: callData.messageId, status: ["senderStatus": false])
            updateAllStatus(messageId: callData.messageId)
        }
    }
}

extension CallVC {
    private func joinVoiceRoom() {
        isJoined = true
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
        
        configs = [
            "channelName": channelName,
            "audioProfile": profile,
            "audioScenario": scenario
        ]
        
        AgoraManager.shared.generateToken(channelName: channelName, uid: 0) {
            self.test()
        }
    }
    
    private func test() {
        isJoined = true
        
        guard let channelName = configs["channelName"] as? String,
            let audioProfile = configs["audioProfile"] as? AgoraAudioProfile,
            let audioScenario = configs["audioScenario"] as? AgoraAudioScenario
            else { return }
        
        // set up agora instance when view loaded
        let config = AgoraRtcEngineConfig()
        config.appId = KeyCenter.AppId
        config.areaCode = GlobalSettings.shared.area
        config.channelProfile = .liveBroadcasting
        // set audio scenario
        config.audioScenario = audioScenario
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        
        // make myself a broadcaster
        agoraKit.setClientRole(GlobalSettings.shared.getUserRole())
        
        // disable video module
        agoraKit.disableVideo()
        
        agoraKit.enableAudio()
        
        // set audio profile
        agoraKit.setAudioProfile(audioProfile)
        // Set audio route to speaker
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        // enable volume indicator
        agoraKit.enableAudioVolumeIndication(200, smooth: 3, reportVad: true)
    
        let option = AgoraRtcChannelMediaOptions()
        option.publishCameraTrack = false
        option.publishMicrophoneTrack = true
        option.clientRoleType = GlobalSettings.shared.getUserRole()
        
        agoraKit.joinChannel(
            byToken: KeyCenter.Token,
            channelId: channelName,
            uid: 0,
            mediaOptions: option
        )
    }
}
