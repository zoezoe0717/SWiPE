//
//  JoinChannelVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/1.
//

import UIKit
import AgoraRtcKit

class JoinChannelVC: UIViewController, AgoraRtcEngineDelegate {
    var agoraKit: AgoraRtcEngineKit!
    var configs: [String:Any] = [:]
    var isJoined: Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        test()
    }
    
    private func test() {
        guard let channelName = configs["channelName"] as? String,
            let audioProfile = configs["audioProfile"] as? AgoraAudioProfile,
            let audioScenario = configs["audioScenario"] as? AgoraAudioScenario
            else { return }
        

        // set up agora instance when view loaded
        let config = AgoraRtcEngineConfig()
        config.appId = KeyCenter.AppId
        config.areaCode = GlobalSettings.shared.area
        config.channelProfile = .liveBroadcasting
        // set audio scenario
        config.audioScenario = audioScenario
        agoraKit = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        
        // make myself a broadcaster
        agoraKit.setClientRole(GlobalSettings.shared.getUserRole())
        
        // disable video module
        agoraKit.disableVideo()
        
        agoraKit.enableAudio()
        
        // set audio profile
        agoraKit.setAudioProfile(audioProfile)
        
        // Set audio route to speaker
        agoraKit.setDefaultAudioRouteToSpeakerphone(true)
        
        // enable volume indicator
        agoraKit.enableAudioVolumeIndication(200, smooth: 3, reportVad: true)
        
//        recordingVolumeSlider.maximumValue = 400
//        recordingVolumeSlider.minimumValue = 0
//        recordingVolumeSlider.integerValue = 100
//
//        playbackVolumeSlider.maximumValue = 400
//        playbackVolumeSlider.minimumValue = 0
//        playbackVolumeSlider.integerValue = 100
//
//        inEarMonitoringVolumeSlider.maximumValue = 100
//        inEarMonitoringVolumeSlider.minimumValue = 0
//        inEarMonitoringVolumeSlider.integerValue = 100
        
        // start joining channel
        // 1. Users can only see each other after they join the
        // same channel successfully using the same app id.
        // 2. If app certificate is turned on at dashboard, token is needed
        // when joining channel. The channel name and uid used to calculate
        // the token has to match the ones used for channel join
        let option = AgoraRtcChannelMediaOptions()
        option.publishCameraTrack = false
        option.publishMicrophoneTrack = true
        option.clientRoleType = GlobalSettings.shared.getUserRole()
        
        let result = agoraKit.joinChannel(byToken: KeyCenter.Token, channelId: channelName, uid: 0, mediaOptions: option)
        if result != 0 {
            // Usually happens with invalid parameters
            // Error code description can be found at:
            // en: https://docs.agora.io/en/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
            // cn: https://docs.agora.io/cn/Voice/API%20Reference/oc/Constants/AgoraErrorCode.html
//            self.showAlert(title: "Error", message: "joinChannel call failed: \(result), please check your params")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 关闭耳返
        agoraKit.enable(inEarMonitoring: false)
        agoraKit.disableAudio()
        agoraKit.disableVideo()
        if isJoined {
            agoraKit.leaveChannel { (stats) -> Void in
                print("left channel, duration: \(stats.duration)")
            }
        }
    }
}
