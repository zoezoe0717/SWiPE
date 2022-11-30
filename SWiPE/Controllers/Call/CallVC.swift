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
    var status: CallStatus? {
        didSet {
            print("---->]\(status)")
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
        callStatusListener()
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
    
    private func addCallRequest() {
        guard let roomId = roomId,
        let receiver = receiver,
        let sender = sender else { return }
        
        if isSender {
            ChatManager.shared.addCallRequest(
                roomId: roomId,
                sender: sender,
                receiver: receiver) { result in
                    switch result {
                    case .success(let success):
                        print(success)
                    case .failure(let error):
                        print(error)
                    }
            }
        }
    }
    
    private func callStatusListener() {
        guard let roomId = roomId else { return }
        
        ChatManager.shared.addStatusListener(room: roomId) { [weak self] result in
            switch result {
            case .success(let success):
                self?.status = success
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func joinVoiceRoom() {
        guard let channelName = callData?.roomId else { return }
        
        let profile: AgoraAudioProfile = .default
        let scenario: AgoraAudioScenario = .default
        
        let configs = [
            "channelName": channelName,
            "audioProfile": profile,
            "audioScenario": scenario
        ] as [String: Any]
              
        AgoraManager.shared.generateToken(channelName: channelName, uid: 0) {
            guard let channelName = configs["channelName"] as? String,
                let audioProfile = configs["audioProfile"] as? AgoraAudioProfile,
                let audioScenario = configs["audioScenario"] as? AgoraAudioScenario
                else { return }
            
            guard var agoraKit = self.agoraKit else { return }
            
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
            
            agoraKit.joinChannel(byToken: KeyCenter.Token, channelId: channelName, uid: 0, mediaOptions: option)
        }
    }
    
    private func updateStatus(status: [String: Bool]) {
        guard let callData = callData else { return }
        ChatManager.shared.updateCallStatus(roomId: callData.roomId, data: status)
    }
    
    @IBAction func acceptCall(_ sender: Any) {
        updateStatus(status: ["receiverStatus": true])
        [phoneAcceptButton, phoneRejectButton].forEach { button in
            button?.isHidden = true
        }
        endButton.isHidden = false
    }
    
    @IBAction func rejectCall(_ sender: Any) {
    }
    
    @IBAction func endCall(_ sender: Any) {
    }
}
