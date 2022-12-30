//
//  ConstantsFile.swift
//  SWiPE
//
//  Created by Zoe on 2022/10/31.
//

import Foundation
import UIKit
import KeychainSwift
import FirebaseAuth

struct UserUid {
    static var share = UserUid()

    let keychain = KeychainSwift()

    func setUidKeychain(uid: String) {
        keychain.set(uid, forKey: "UID")
    }

    func getUidKeychain() -> String {
        return keychain.get("UID") ?? ""
    }
    
    func getUid() -> String {
        guard let uid = Auth.auth().currentUser else { return ""}
        return uid.uid
    }
}

enum Constants {
    enum ChatVCString {
        static let title = "Message"
    }

    enum SignVCString {
        static let welcome = "歡迎來到SWiPE!"
        
        static let signup = "或是建立帳號"
        
        static let login = "登入"
        static let subTitle = "點選「登入」代表你同意我們的隱私權政策"
    }

    enum LottieString {
        static let cardLoding = "CardLoding"
        static let match = "Match"
        static let signSheep = "SignSheep"
        static let arrow = "Arrow"
        static let backArrow = "BackArrow"
        static let swimmingSheep = "SwimmingSheep"
        static let calling = "Calling"
    }

    enum ProfileString {
        static let updatePhoto = "更新頭貼"
        static let updateVideo = "更新影片"
        static let setting = "設定"
    }
    
    enum AlertSrting {
        static let confirm = "確定"
        static let success = "成功"
        static let error = "錯誤"
        static let canael = "取消"
        static let prosecution = "檢舉"
        static let prosecutionSubTitle = "您確定要檢舉嗎？"
        static let reportDetail = "    我們已收到您的檢舉。工作人員會在24小時內檢視該問題，如該用戶有違規，我們將會懲處該用戶"
        static let reportSubTitle = "此檢舉將會匿名，我們將會在24小時內為您處理。"
    }
    
    enum UploadVCString {
        static let add = "點我新增"
        static let confirm = "確定"
        static let reselect = "重新選擇"
    }
    static let reportSubTitle = "此檢舉將會匿名，我們將會在24小時內為您處理。"

    enum UploadPhotoStr {
        static let faceAlertTitle = "未偵測到臉部"
        static let faceAlertMessage = "請重新選擇有臉部的照片喔！"
    }
}

enum CustomColor {
    case base
    
    case main
    
    case text
    
    case secondary
        
    var color: UIColor {
        switch self {
        case .base:
            return UIColor(named: "BaseColor") ?? .systemGray6
            
        case .main:
            return UIColor(named: "MainColor") ?? .systemRed
            
        case .text:
            return UIColor(named: "TextColor") ?? .black
            
        case .secondary:
            return UIColor(named: "SecondaryColor") ?? .yellow
        }
    }
}
