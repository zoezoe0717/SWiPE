//
//  CallVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/30.
//

import UIKit
import AgoraRtcKit

class CallVC: UIViewController {
    var roomId: String?
    var receiver: User?
    var sender: User?
    var callData: Call?
    var isSender = false
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var phoneAcceptButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    
    @IBOutlet weak var phoneRejectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCallRequest()
        setUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isSender {
            updateStatus(status: ["receiverStatus": false])
            updateStatus(status: ["senderStatus": false])
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
            print("")
        }
    }
    
    private func updateStatus(status: [String: Bool]) {
        guard let callData = callData else { return }
        ChatManager.shared.updateCallStatus(messageId: callData.messageId, data: status)
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
