//
//  ProfileVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/4.
//

import UIKit
import YPImagePicker

class ProfileVC: UIViewController {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var editVideoButton: UIButton!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var updatePhotoLabel: UILabel!
    @IBOutlet weak var updateVideoLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var settingLabel: UILabel!
    
    var user: User? {
        didSet {
            guard let user = user else { return }
            userImageView.loadImage(user.story)
            userName.text = "\(user.name)"
        }
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        getUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setUI() {
        bottomBackgroundView.backgroundColor = CustomColor.main.color
        bottomBackgroundView.layer.cornerRadius = 50
        
        [updatePhotoLabel, updateVideoLabel, settingLabel].forEach { label in
            label?.textColor = CustomColor.base.color
        }
        updatePhotoLabel.text = Constants.ProfileString.updatePhoto
        updateVideoLabel.text = Constants.ProfileString.updateVideo
        settingLabel.text = Constants.ProfileString.setting
    }
    
    private func getUser() {
        FireBaseManager.shared.getUserListener { [weak self] result in
            switch result {
            case .success(let user):
                self?.user = user
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func uploadData() {
        if let image = userImageView.image {
            UploadStoryProvider.shared.uploadImageWithImgur(image: image) { result in
                switch result {
                case .success(let url):
                    SignVC.userData.story = "\(url)"
                    FireBaseManager.shared.updateUserData(user: SignVC.userData, data: ["story": "\(url)"])
                case .failure(let failure):
                    print(failure)
                }
            }
        }
    }
    
    @IBAction func updateProfileImage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let controller = storyboard.instantiateViewController(withIdentifier: "\(UploadPhotoVC.self)") as? UploadPhotoVC {
            controller.isNewUser = false
            present(controller, animated: true)
        }
    }
    
    @IBAction func updateVideo(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let controller = storyboard.instantiateViewController(withIdentifier: "\(UploadVideoVC.self)") as? UploadVideoVC {
            controller.isNewUser = false
            present(controller, animated: true)
        }
    }
    
    @IBAction func presentSetting(_ sender: Any) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "\(SettingVC.self)") as? SettingVC {
            controller.modalPresentationStyle = .fullScreen
            controller.user = user
            present(controller, animated: true)
        }
    }
}
