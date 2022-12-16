//
//  UITableView+Ext.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/8.
//

import UIKit

extension UITableView {
    func zRegisterCellWithNib(identifier: String, bundle: Bundle?) {
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forCellReuseIdentifier: identifier)
    }
}

extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
