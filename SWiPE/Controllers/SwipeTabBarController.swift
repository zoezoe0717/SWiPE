//
//  SwipeTabBarController.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/13.
//

import UIKit
import FirebaseAuth

class SwipeTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = CustomColor.main.color
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        loginJudgment()
    }
    
    private func loginJudgment() {
        Auth.auth().addStateDidChangeListener { _, user in
            if let user = user {
                print("\(user.uid) login")
            } else {
                self.presentSignPage()
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
}
