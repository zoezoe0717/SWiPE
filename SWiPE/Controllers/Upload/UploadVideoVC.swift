//
//  UploadVideoVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/10.
//

import UIKit
import YPImagePicker
import AVFoundation
import AVKit

class UploadVideoVC: UploadVC {
    @IBOutlet weak var videoView: UIView!
    
    lazy private var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: queuePlayer)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    private var playerLooper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?
    
    private var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setUI() {
        videoView.isHidden = true
        
        [createButton, pushButton, cancelButton].forEach { sub in
            view.addSubview(sub)
            sub.translatesAutoresizingMaskIntoConstraints = false
        }
        
        buttonSwitch(hasImage: false)
        
        NSLayoutConstraint.activate([
            createButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 40),

            pushButton.topAnchor.constraint(equalTo: videoView.bottomAnchor, constant: 40),
            pushButton.rightAnchor.constraint(equalTo: videoView.rightAnchor),
            pushButton.heightAnchor.constraint(equalToConstant: 40),
            pushButton.widthAnchor.constraint(equalToConstant: 80),
            
            cancelButton.topAnchor.constraint(equalTo: videoView.bottomAnchor, constant: 40),
            cancelButton.leftAnchor.constraint(equalTo: videoView.leftAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func createVideo(url: URL) {
        videoUrl = url
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        queuePlayer = AVQueuePlayer(playerItem: item)
        
        playerLayer = AVPlayerLayer(player: queuePlayer)
        
        if let queuePlayer = queuePlayer {
            playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
            videoView.layer.addSublayer(playerLayer)
            playerLayer.frame = videoView.bounds
            queuePlayer.play()
        }
    }
    
    private func clearVideo() {
        if let queuePlayer = queuePlayer {
            let items = queuePlayer.items()
            queuePlayer.remove(items[0])
        }
    }
    
    override func uploadData() {
        if let videoUrl = videoUrl {
            UploadStoryProvider.shared.uploadVideo(url: videoUrl) { result in
                switch result {
                case .success(let url):
                    AddDataVC.newUser.video = "\(url)"
                    FireBaseManager.shared.updateUserData(user: AddDataVC.newUser, data: ["video": "\(url)"])
                case .failure(let failure):
                    print(failure)
                }
            }
        }
        
        if isNewUser {
            if let controller = storyboard?.instantiateViewController(withIdentifier: "MainTableBar") {
                controller.modalPresentationStyle = .fullScreen
                present(controller, animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
        
    override func createCamera() {
        queuePlayer?.pause()
        
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .video]
        config.library.mediaType = .video
        config.video.recordingTimeLimit = 30.0
        config.video.libraryTimeLimit = 30.0
        config.onlySquareImagesFromCamera = false
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            self.queuePlayer?.play()
            
            if let video = items.singleVideo {
                DispatchQueue.main.async {
                    self.videoView.isHidden = false
                    self.createVideo(url: video.url)
                    self.buttonSwitch(hasImage: true)
                    self.clearVideo()
                }
            }
            picker.dismiss(animated: true)
        }
        self.present(picker, animated: true)
    }
}
