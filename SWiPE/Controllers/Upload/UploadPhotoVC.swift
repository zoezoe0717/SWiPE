//
//  UploadPhotoVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/10.
//

import UIKit
import YPImagePicker

class UploadPhotoVC: UIViewController {
    lazy private var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("點我新增頭像", for: .normal)
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        return button
    }()
    
    lazy private var pushButton: UIButton = {
        let button = UIButton()
        button.setTitle("確定", for: .normal)
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(pushImage), for: .touchUpInside)
        return button
    }()
    
    lazy private var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("重新選擇", for: .normal)
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        return button
    }()
    
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
    
    private func buttonSwitch(hasImage: Bool) {
        if hasImage {
            createButton.isHidden = true
            pushButton.isHidden = false
            cancelButton.isHidden = false
        } else {
            createButton.isHidden = false
            pushButton.isHidden = true
            cancelButton.isHidden = true
        }
    }
    
    private func createCamera() {
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

    @objc func openCamera() {
        createCamera()
    }
        
    @objc private func pushImage() {
        print("上傳")
    }
}
