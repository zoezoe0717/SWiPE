//
//  ConstantsFile.swift
//  SWiPE
//
//  Created by Zoe on 2022/10/31.
//

import Foundation
import UIKit

enum CustomColor {
    case base
    
    case tabBar
        
    var color: UIColor {
        switch self {
        case .base:
            return UIColor(named: "BaseColor") ?? .systemGray6
            
        case .tabBar:
            return UIColor(named: "TabBarColor") ?? .systemRed
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
    case signCat = "SignCat"
    case arrow = "Arrow"
}
