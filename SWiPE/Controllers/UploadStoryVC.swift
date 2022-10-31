//
//  updateStoryVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/10/29.
//

import UIKit
import AVKit
import PhotosUI

class UploadStoryVC: UIViewController {

    @IBOutlet weak var showStoryView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func uploadStory(_ sender: Any) {
        var configuration = PHPickerConfiguration()

        let pickerAlertController = UIAlertController(title: "上傳圖片", message: "請選擇要上傳的圖片", preferredStyle: .actionSheet)
        
        let fromLibAction = UIAlertAction(title: "照片圖庫", style: .default) { _ in
            configuration.selectionLimit = 1
            configuration.filter = .any(of: [.videos, .images])
            configuration.preferredAssetRepresentationMode = .current
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true)
        }
        
        let fromCameraAction = UIAlertAction(title: "相機", style: .default) { _ in
            print("dd")
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { _ in
            pickerAlertController.dismiss(animated: true)
        }
        
        [fromLibAction, fromCameraAction, cancelAction].forEach { pickerAlertController.addAction($0)}
        present(pickerAlertController, animated: true, completion: nil)
    }
}

//MARK: - PHPickerViewControllerDelegate
extension UploadStoryVC: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        print(Thread.isMainThread)
        
        guard let result = results.first else { return }
        let assetid = result.assetIdentifier
        
        print(assetid as Any)
        
        let provider = result.itemProvider
        let types = provider.registeredTypeIdentifiers
        print("types: \(types)")
        
        if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            self.dealWithVideo(result)
        } else if provider.canLoadObject(ofClass: UIImage.self) {
            self.dealWithImage(result)
        }
    }
    
    private func dealWithVideo(_ result: PHPickerResult) {
        clearAll()
        let movie = UTType.movie.identifier
        let provider = result.itemProvider
        
        provider.loadFileRepresentation(forTypeIdentifier: movie) { url, error in
            if let url = url {
                DispatchQueue.main.sync {
                    let loopType = "com.apple.private.auto-loop-gif"
                    if provider.hasItemConformingToTypeIdentifier(loopType) {
                        //                        self.showLoopingMovie(url: url)
                    } else {
                        self.showMovie(url: url)
                    }
                }
            }
        }
    }
    
    private func dealWithImage(_ result: PHPickerResult) {
        clearAll()
        let provider = result.itemProvider
        
        provider.loadObject(ofClass: UIImage.self) { image, error in
            if let image = image as? UIImage {
                UploadStoryProvider.shared.uploadPhoto(image: image) { result in
                    switch result {
                    case .success(let url):
                        print(url)
                    case .failure(let error):
                        print(error)
                    }
                }
                DispatchQueue.main.async {
                    self.showStoryView.image = image
                }
            }
        }
    }
    
    private func showMovie(url: URL) {
        clearAll()
        let av = AVPlayerViewController()
        let player = AVPlayer(url:url)
        av.player = player
        self.addChild(av)
        av.view.frame = self.showStoryView.bounds
        av.view.backgroundColor = self.showStoryView.backgroundColor
        self.showStoryView.addSubview(av.view)
        av.didMove(toParent: self)
        player.play()
    }
    
    private func clearAll() {
        if self.children.count > 0 {
            let avPlayer = self.children[0] as! AVPlayerViewController
            avPlayer.willMove(toParent: nil)
            avPlayer.view.removeFromSuperview()
            avPlayer.removeFromParent()
        }
        self.showStoryView.subviews.forEach { $0.removeFromSuperview() }
    }
}

