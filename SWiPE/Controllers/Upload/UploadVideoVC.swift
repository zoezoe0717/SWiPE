//
//  UploadVideoVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/10.
//

import UIKit
import YPImagePicker

class UploadVideoVC: UIViewController {
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCamera()
    }
    
    private func setCamera() {
        var config = YPImagePickerConfiguration()
        config.screens = [.library, .video]
        config.library.mediaType = .video
        config.onlySquareImagesFromCamera = false
        
        let picker = YPImagePicker(configuration: config)
        picker.didFinishPicking { [unowned picker] items, _ in
            if let video = items.singleVideo {
                print(video.fromCamera)
                print(video.url)
            }
            picker.dismiss(animated: true)
        }
        self.present(picker, animated: true)
    }
}
