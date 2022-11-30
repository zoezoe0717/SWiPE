//
//  String+Ext.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/30.
//

import Foundation

extension String {
    var timeStamp: String {
        let date = Date()
        let timeInterval = date.timeIntervalSince1970
        let millisecond = CLongLong(timeInterval * 1000)
        return "\(millisecond)"
    }
}
