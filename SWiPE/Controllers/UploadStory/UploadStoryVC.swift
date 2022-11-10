//
//  updateStoryVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/10/29.
//

import UIKit
import AVKit
import PhotosUI
import Alamofire

class UploadStoryVC: UIViewController {
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    @IBOutlet weak var showStoryView: UIImageView!
    
    var userImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonSwitch(showChoose: true)
    }
    
    private func buttonSwitch(showChoose: Bool) {
        if showChoose {
            chooseButton.isHidden = false
            cancelButton.isHidden = true
            uploadButton.isHidden = true
        } else {
            chooseButton.isHidden = true
            cancelButton.isHidden = false
            uploadButton.isHidden = false
        }
    }
    
    @IBAction func choose(_ sender: Any) {
        var configuration = PHPickerConfiguration()

        let pickerAlertController = UIAlertController(
            title: UploadStoryString.uploadImage.rawValue,
            message: UploadStoryString.chooseUploadImage.rawValue,
            preferredStyle: .actionSheet
        )
        let fromLibAction = UIAlertAction(title: UploadStoryString.photoLibrary.rawValue, style: .default) { _ in
            configuration.selectionLimit = 1
            configuration.filter = .any(of: [.images])
            configuration.preferredAssetRepresentationMode = .current

            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            self.present(picker, animated: true)
        }
        let fromCameraAction = UIAlertAction(title: UploadStoryString.camera.rawValue, style: .default) { _ in
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        }
        let cancelAction = UIAlertAction(title: UploadStoryString.cancel.rawValue, style: .cancel) { _ in
            pickerAlertController.dismiss(animated: true)
        }
        [fromLibAction, fromCameraAction, cancelAction].forEach { pickerAlertController.addAction($0) }
        
        present(pickerAlertController, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        buttonSwitch(showChoose: true)
    }
    
    @IBAction func upload(_ sender: Any) {
        guard let userImage = userImage else { return }
        UploadStoryProvider.shared.uploadPhoto(image: userImage) { result in
            switch result {
            case .success(let url):
                AddDataVC.newUser.story = "\(url)"
                FireBaseManager.shared.updateStory(user: AddDataVC.newUser)
                
            case .failure(let error):
                print(error)
            }
        }
        buttonSwitch(showChoose: true)
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "MainTableBar") {
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension UploadStoryVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }
        let provider = result.itemProvider
        _ = provider.registeredTypeIdentifiers
        if provider.canLoadObject(ofClass: UIImage.self) {
            self.dealWithImage(result)
        }
    }
    
    private func dealWithImage(_ result: PHPickerResult) {
        clearAll()
        let provider = result.itemProvider
        provider.loadObject(ofClass: UIImage.self) { image, _ in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self.userImage = image
                    self.showStoryView.image = image
                    self.buttonSwitch(showChoose: false)
                }
            }
        }
    }

    private func clearAll() {
        if !self.children.isEmpty {
            guard let avPlayer = self.children[0] as? AVPlayerViewController else { return }
            avPlayer.willMove(toParent: nil)
            avPlayer.view.removeFromSuperview()
            avPlayer.removeFromParent()
        }
        self.showStoryView.subviews.forEach { $0.removeFromSuperview() }
    }
}

extension UploadStoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            showStoryView.image = image
            userImage = image
            buttonSwitch(showChoose: false)
        }
        dismiss(animated: true)
    }
}
