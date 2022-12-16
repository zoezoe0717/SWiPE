//
//  Audio.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/5.
//

import Foundation
import AVFoundation

func configureAudioSession() {
  print("Configuring audio session")
  let session = AVAudioSession.sharedInstance()
  do {
    try session.setCategory(.playAndRecord, mode: .voiceChat, options: [])
  } catch (let error) {
    print("Error while configuring audio session: \(error)")
  }
}

func startAudio() {
  print("Starting audio")
}

func stopAudio() {
  print("Stopping audio")
}
