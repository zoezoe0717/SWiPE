//
//  MainVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/4.
//

import UIKit
import FirebaseAuth

class MainVC: UIViewController {
    var user: User? {
        didSet {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let user = user else { return }

            if user.story.isEmpty {
                if let controller = storyboard.instantiateViewController(withIdentifier: "\(UploadPhotoVC.self)") as? UploadPhotoVC {
                    controller.modalPresentationStyle = .fullScreen
                    present(controller, animated: false)
                }
            } else if user.video.isEmpty {
                if let controller = storyboard.instantiateViewController(withIdentifier: "\(UploadVideoVC.self)") as? UploadVideoVC {
                    controller.modalPresentationStyle = .fullScreen
                    present(controller, animated: false)
                }
            } else {
                presentMainPage()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginJudgment()
    }

    private func loginJudgment() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let `self` = self else { return }
            if let user = user {
                self.getUser()
            } else {
                self.presentSignPage()
            }
        }
    }
    
    private func getUser() {
        FireBaseManager.shared.getUser { [weak self] result in
            switch result {
            case .success(let userData):
                self?.user = userData
            case .failure(let failure):
                fatalError("Error: \(failure)")
            }
        }
    }
        
    private func presentSignPage() {
        let storyboard = UIStoryboard(name: "Sign", bundle: nil)
        
        if let controller = storyboard.instantiateViewController(withIdentifier: "\(SignVC.self)") as? SignVC {
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: false)
        }
    }
    
    private func presentMainPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let controller = storyboard.instantiateViewController(withIdentifier: "\(SwipeTabBarController.self)") as? SwipeTabBarController {
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: false)
        }
    }
}
