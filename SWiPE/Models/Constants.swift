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
    
    case cardBottomColor
        
    var color: UIColor {
        switch self {
        case .base:
            return UIColor(named: "baseColor") ?? .systemGray6
            
        case .cardBottomColor:
            return UIColor(named: "cardBottomColor") ?? .systemGray6
        }
    }
}
