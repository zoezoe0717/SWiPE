//
//  UploadPhotoVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/10.
//

import UIKit
import YPImagePicker

class UploadPhotoVC: UploadVC {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileImagePhoto: UIImageView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        titleLabel.textColor = CustomColor.text.color
        
        profileImagePhoto.isHidden = true
        profileImagePhoto.layer.cornerRadius = 20
        profileImagePhoto.layer.borderColor = CustomColor.text.color.cgColor
        profileImagePhoto.layer.borderWidth = 3
        
        [createButton, pushButton, cancelButton].forEach { sub in
            view.addSubview(sub)
            sub.translatesAutoresizingMaskIntoConstraints = false
        }
        
        buttonSwitch(hasImage: false)
        
        NSLayoutConstraint.activate([
            createButton.topAnchor.constraint(equalTo: profileImagePhoto.bottomAnchor, constant: 40),
            createButton.centerXAnchor.constraint(equalTo: profileImagePhoto.centerXAnchor),
            createButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            createButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),

            pushButton.topAnchor.constraint(equalTo: profileImagePhoto.bottomAnchor, constant: 40),
            pushButton.rightAnchor.constraint(equalTo: profileImagePhoto.rightAnchor),
            pushButton.heightAnchor.constraint(equalToConstant: 40),
            pushButton.widthAnchor.constraint(equalToConstant: 80),
            
            cancelButton.topAnchor.constraint(equalTo: profileImagePhoto.bottomAnchor, constant: 40),
            cancelButton.leftAnchor.constraint(equalTo: profileImagePhoto.leftAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func updateFirstIndex() {
        FireBaseManager.shared.getFirstIndex { index in
            FireBaseManager.shared.updateUserData(user: SignVC.userData, data: ["index": index])
        }
    }
    
    override func uploadData() {
        ProgressHUD.show()

        if let image = profileImagePhoto.image {
            UploadStoryProvider.shared.uploadPhoto(image: image) { [weak self] result in
                switch result {
                case .success(let url):
                    SignVC.userData.story = "\(url)"
                    FireBaseManager.shared.updateUserData(user: SignVC.userData, data: ["story": "\(url)"])
                    ProgressHUD.dismiss()
                case .failure(let failure):
                    print(failure)
                    ProgressHUD.dismiss()
                }
            }
        }

        if isNewUser {
            updateFirstIndex()
            if let controller = storyboard?.instantiateViewController(withIdentifier: "\(UploadVideoVC.self)") as? UploadVideoVC {
                controller.modalPresentationStyle = .fullScreen
                present(controller, animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    override func createCamera() {
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                DispatchQueue.main.async { [weak self] in
                    self?.profileImagePhoto.image = photo.image
                    self?.profileImagePhoto.isHidden = false
                    self?.buttonSwitch(hasImage: true)
                }
            }
            picker.dismiss(animated: true)
        }
        present(picker, animated: true)
    }
}
