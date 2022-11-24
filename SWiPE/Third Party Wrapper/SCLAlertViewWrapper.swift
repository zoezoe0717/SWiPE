//
//  Wrapper.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/24.
//

import Foundation
import SCLAlertView

class ZAlertView {
    static let share = ZAlertView()
    
    func editView(message: AlertMessage, user: User, dataType: String) {
        let alert = SCLAlertView()
        let textField = alert.addTextField(message.text)
        
        alert.addButton(AlertSrting.confirm.rawValue) {
            guard let text = textField.text else { return }
            if !text.isEmpty {
                SCLAlertView().showSuccess(AlertSrting.success.rawValue, subTitle: message.successSubTitle)
                FireBaseManager.shared.updateUserData(user: user, data: [dataType: text])
            } else {
                SCLAlertView().showError(AlertSrting.error.rawValue, subTitle: message.errorSubTitle)
            }
        }
        
        alert.showTitle(
            message.alertTitle,
            subTitle: message.alertSubTitle,
            timeout: nil,
            completeText: AlertSrting.canael.rawValue,
            style: .edit
        )
    }
}

struct AlertMessage {
    let text: String
    let successSubTitle: String
    let errorSubTitle: String
    let alertTitle: String
    let alertSubTitle: String
}

enum AlertSrting: String {
    case confirm = "確定"
    case success = "成功"
    case error = "錯誤"
    case canael = "取消"
}
