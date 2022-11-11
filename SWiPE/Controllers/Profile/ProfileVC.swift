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
        
    var user: User? {
        didSet {
            guard let user = user else { return }
            userImageView.loadImage(user.story)
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
        view.backgroundColor = CustomColor.base.color
    }
    
    private func getUser() {
        FireBaseManager.shared.getUser { result in
            switch result {
            case .success(let user):
                self.user = user
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    private func uploadData() {
        if let image = userImageView.image {
            UploadStoryProvider.shared.uploadPhoto(image: image) { result in
                switch result {
                case .success(let url):
                    AddDataVC.newUser.story = "\(url)"
                    FireBaseManager.shared.updateUserData(user: AddDataVC.newUser, data: ["story": "\(url)"])
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
    
    @IBAction func showEditPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let controller = storyboard.instantiateViewController(withIdentifier: "\(UploadVideoVC.self)") as? UploadVideoVC {
            controller.isNewUser = false
            present(controller, animated: true)
        }
    }
}
