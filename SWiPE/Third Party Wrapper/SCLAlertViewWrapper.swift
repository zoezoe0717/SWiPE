//
//  Wrapper.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/24.
//

import Foundation
import SCLAlertView

class ZAlertView {
    static let shared = ZAlertView()
    
    let alert = SCLAlertView()
    var isAngry = false
    
    func editView(message: AlertMessage, user: User, dataType: String) {
        let alert = SCLAlertView()
        let textField = alert.addTextField(message.text)
        
        alert.addButton(Constants.AlertSrting.confirm) {
            guard let text = textField.text else { return }
            if !text.isEmpty {
                SCLAlertView().showSuccess(Constants.AlertSrting.success, subTitle: message.successSubTitle)
                FireBaseManager.shared.updateUserData(user: user, data: [dataType: text])
            } else {
                SCLAlertView().showError(Constants.AlertSrting.error, subTitle: message.errorSubTitle)
            }
        }
        
        alert.showTitle(
            message.alertTitle,
            subTitle: message.alertSubTitle,
            timeout: nil,
            completeText: Constants.AlertSrting.canael,
            style: .edit
        )
    }
    
    func blockView(message: AlertMessage, roomID: String) {
        let alert = SCLAlertView()
        alert.addButton(Constants.AlertSrting.confirm) {
            ChatManager.shared.blockFriend(roomID: roomID)
        }
        
        let image = UIImage(named: "block")
                
        alert.showTitle(
            message.alertTitle,
            subTitle: message.alertSubTitle,
            timeout: nil,
            completeText: Constants.AlertSrting.canael,
            style: .warning,
            colorStyle: 0xF1BF7F,
            circleIconImage: image
        )
    }
    
    func angryView(message: AlertMessage, roomID: String) {
        let alert = SCLAlertView()
        guard let isAngry = message.isAngry else { return }
        alert.addButton(Constants.AlertSrting.confirm) {
            ChatManager.shared.updateData(roomID: roomID, data: ["isAngry": isAngry])
        }
        
        let image = UIImage(named: "angry")
                
        alert.showTitle(
            message.alertTitle,
            subTitle: message.alertSubTitle,
            timeout: nil,
            completeText: Constants.AlertSrting.canael,
            style: .warning,
            circleIconImage: image
        )
    }
    
    func showProsecute(id: String, completion: @escaping ((Bool) -> Void)) {
        let alert = SCLAlertView()
        alert.addButton(Constants.AlertSrting.prosecution) {
            FireBaseManager.shared.addProsecute(id: id)
            SCLAlertView().showSuccess(Constants.AlertSrting.success, subTitle: Constants.AlertSrting.reportDetail)
        }
        alert.addButton("拉黑") {
            completion(true)
            SCLAlertView().showSuccess(Constants.AlertSrting.success, subTitle: "已成功將此用戶加入黑名單中，您在也無法看到該用戶的任何內容")
        }
        
        alert.showTitle(
            "您想要做什麼呢？",
            subTitle: "我們可以提供您以下協助",
            timeout: nil,
            completeText: Constants.AlertSrting.canael,
            style: .warning,
            colorStyle: 0xF1BF7F
        )
    }
    
//    func showProsecute(id: String) {
//        let alert = SCLAlertView()
//        alert.addButton(Constants.AlertSrting.prosecution) {
//            FireBaseManager.shared.addProsecute(id: id)
//            SCLAlertView().showSuccess(Constants.AlertSrting.success, subTitle: Constants.AlertSrting.reportDetail)
//        }
//
//        alert.showTitle(
//            Constants.AlertSrting.prosecutionSubTitle,
//            subTitle: Constants.AlertSrting.reportSubTitle,
//            timeout: nil,
//            completeText: Constants.AlertSrting.canael,
//            style: .warning,
//            colorStyle: 0xF1BF7F
//        )
//    }
}

struct AlertMessage {
    var text: String = ""
    var successSubTitle: String = ""
    var errorSubTitle: String = ""
    let alertTitle: String
    let alertSubTitle: String
    var isAngry: Bool?
}
