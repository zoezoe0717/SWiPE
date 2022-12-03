//
//  MainVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/4.
//

import UIKit
import FirebaseAuth

class MainVC: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginJudgment()
    }

    private func loginJudgment() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                print("\(user.uid) Login")
                self?.presentMainPage()
            } else {
                self?.presentSignPage()
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
