//
//  UploadPhotoVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/10.
//

import UIKit
import YPImagePicker

class UploadPhotoVC: UploadVC {
    @IBOutlet weak var profileImagePhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        [createButton, pushButton, cancelButton].forEach { sub in
            view.addSubview(sub)
            sub.translatesAutoresizingMaskIntoConstraints = false
        }
        
        buttonSwitch(hasImage: false)
        
        NSLayoutConstraint.activate([
            createButton.topAnchor.constraint(equalTo: profileImagePhoto.bottomAnchor, constant: 40),
            createButton.centerXAnchor.constraint(equalTo: profileImagePhoto.centerXAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 40),

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
    
    override func createCamera() {
        let picker = YPImagePicker()
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                DispatchQueue.main.async { [self] in
                    self.profileImagePhoto.image = photo.image
                    self.buttonSwitch(hasImage: true)
                }
            }
            picker.dismiss(animated: true)
        }
        present(picker, animated: true)
    }
}
