//
//  AgoraAudioEffectPreset+Ext.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/3.
//

import Foundation
import AgoraRtcKit

extension AgoraAudioEffectPreset {
    func description() -> String {
        switch self {
        case .off: return "原聲"
        case .voiceChangerEffectOldMan: return "老男人"
        case .voiceChangerEffectBoy: return "小男孩"
        case .voiceChangerEffectSister: return "大姊姊"
        case .voiceChangerEffectGirl: return "小女孩"
        case .voiceChangerEffectPigKin: return "豬八戒"
        case .voiceChangerEffectHulk: return "浩克"

        default:
            return "\(self.rawValue)"
        }
    }
}
