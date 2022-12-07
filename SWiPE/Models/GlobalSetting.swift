//
//  GlobalSetting.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/30.
//

import Foundation
import AgoraRtcKit

struct SettingItemOption {
    var idx: Int
    var label: String
    var value: Any
}

class SettingItem {
    var selected: Int
    var options: [SettingItemOption]
    
    func selectedOption() -> SettingItemOption {
        return options[selected]
    }
    
    init(selected: Int, options: [SettingItemOption]) {
        self.selected = selected
        self.options = options
    }
}

class GlobalSettings {
    var area: AgoraAreaCodeType = .global
    static let shared = GlobalSettings()
    var settings: [String: SettingItem] = [
        "role": SettingItem(selected: 0, options: [
            SettingItemOption(idx: 0, label: "broadcaster", value: AgoraClientRole.broadcaster),
            SettingItemOption(idx: 1, label: "audience", value: AgoraClientRole.audience)
        ])
    ]
    
    func getUserRole() -> AgoraClientRole {
        let item = settings["role"]
        return (item?.selectedOption().value as? AgoraClientRole) ?? .broadcaster
    }
}
