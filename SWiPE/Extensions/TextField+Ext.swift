//
//  TextField+Ext.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/22.
//

import UIKit

extension UITextField {
    func setBottomBorder(placeholder text: String) {
        self.borderStyle = .none
        self.layer.backgroundColor = CustomColor.main.color.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
        
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}
