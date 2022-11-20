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
    
    func getUid() -> String {
        guard let currentUser = Auth.auth().currentUser else { return "" }
        keychain.set(currentUser.uid, forKey: "UID")

        return keychain.get("UID") ?? ""
    }
}

enum CustomColor {
    case base
    
    case main
        
    var color: UIColor {
        switch self {
        case .base:
            return UIColor(named: "BaseColor") ?? .systemGray6
            
        case .main:
            return UIColor(named: "MainColor") ?? .systemRed
        }
    }
}

enum ChatVCString: String {
    case title = "Message"
}

enum SignVCString: String {
    case welcome = "歡迎來到SWiPE!"
    case signup = "或是建立帳號"
    case login = "登入"
}

enum LottieString: String {
    case cardLoding = "CardLoding"
    case match = "Match"
    case signSheep = "SignSheep"
    case arrow = "Arrow"
    case backArrow = "BackArrow"
}
