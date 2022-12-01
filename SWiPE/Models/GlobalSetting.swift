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
        "resolution": SettingItem(selected: 3, options: [
            SettingItemOption(idx: 0, label: "90x90", value: CGSize(width: 90, height: 90)),
            SettingItemOption(idx: 1, label: "160x120", value: CGSize(width: 160, height: 120)),
            SettingItemOption(idx: 2, label: "320x240", value: CGSize(width: 320, height: 240)),
            SettingItemOption(idx: 3, label: "640x360", value: CGSize(width: 640, height: 360)),
            SettingItemOption(idx: 4, label: "1280x720", value: CGSize(width: 1280, height: 720))
        ]),
        "fps": SettingItem(selected: 3, options: [
            SettingItemOption(idx: 0, label: "10fps", value: AgoraVideoFrameRate.fps10),
            SettingItemOption(idx: 1, label: "15fps", value: AgoraVideoFrameRate.fps15),
            SettingItemOption(idx: 2, label: "24fps", value: AgoraVideoFrameRate.fps24),
            SettingItemOption(idx: 3, label: "30fps", value: AgoraVideoFrameRate.fps30),
            SettingItemOption(idx: 4, label: "60fps", value: AgoraVideoFrameRate.fps60)
        ]),
        "orientation": SettingItem(selected: 0, options: [
            SettingItemOption(idx: 0, label: "adaptive", value: AgoraVideoOutputOrientationMode.adaptative),
            SettingItemOption(idx: 1, label: "fixed portrait", value: AgoraVideoOutputOrientationMode.fixedPortrait),
            SettingItemOption(idx: 2, label: "fixed landscape", value: AgoraVideoOutputOrientationMode.fixedLandscape)
        ]),
        "role": SettingItem(selected: 0, options: [
            SettingItemOption(idx: 0, label: "broadcaster", value: AgoraClientRole.broadcaster),
            SettingItemOption(idx: 1, label: "audience", value: AgoraClientRole.audience)
        ]),
    ]
    
    func getSetting(key: String) -> SettingItem? {
        return settings[key]
    }
    
    func getUserRole() -> AgoraClientRole {
        let item = settings["role"]
        return (item?.selectedOption().value as? AgoraClientRole) ?? .broadcaster
    }
}
