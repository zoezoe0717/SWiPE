//
//  CallVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/30.
//

import UIKit

class CallVC: UIViewController {
    var roomId: String?
    var receiverId: String?
    var callData: Call?
    var isSender = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCallRequest()
    }
    
    private func addCallRequest() {
        guard let roomId = roomId,
        let receiverId = receiverId else { return }
        
        if isSender {
            ChatManager.shared.addCallRequest(roomId: roomId, receiverId: receiverId) { result in
                switch result {
                case .success(let success):
                    print(success)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
