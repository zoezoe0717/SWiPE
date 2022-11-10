//
//  PlayManager.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/8.
//

import Foundation
import AVFoundation

class PlayerManager: NSObject {
    static let share = PlayerManager()
    
    lazy var player = AVPlayer()
    
    lazy var layer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: player)
        return layer
    }()
    
    func playUrl(url: String?) {
        guard let urlString = url,
              let url = URL(string: urlString) else { return }
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        player.play()
    }
    
    func stop() {
        player.pause()
    }
}
