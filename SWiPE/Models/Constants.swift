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
