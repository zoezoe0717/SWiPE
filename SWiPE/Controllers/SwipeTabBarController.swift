//
//  SwipeTabBarController.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/13.
//

import UIKit
import FirebaseAuth

class SwipeTabBarController: UITabBarController {
    lazy var customView: UIView = {
        let view = UIView()
        view.backgroundColor = CustomColor.main.color
        view.layer.cornerRadius = 10
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 3 
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = CustomColor.secondary.color
        loginJudgment()
        setUI()
//        clearLogin()
    }
    
    override func viewDidLayoutSubviews() {
        var tabFrame: CGRect = self.tabBar.frame
        tabFrame.size.height = 90
        tabFrame.origin.y = self.view.frame.size.height - 90
        self.tabBar.frame = tabFrame
    }
    
    private func setUI() {
        self.tabBar.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            customView.centerYAnchor.constraint(equalTo: self.tabBar.centerYAnchor),
            customView.centerXAnchor.constraint(equalTo: self.tabBar.centerXAnchor),
            customView.bottomAnchor.constraint(equalTo: self.tabBar.bottomAnchor),
            customView.topAnchor.constraint(equalTo: self.tabBar.topAnchor),
            customView.widthAnchor.constraint(equalTo: self.tabBar.widthAnchor, multiplier: 0.95),
            customView.heightAnchor.constraint(equalTo: self.tabBar.heightAnchor, multiplier: 0.7)
        ])
    }
    
    private func clearLogin() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        UserUid.share.keychain.set("", forKey: "UID")
    }
    
    private func loginJudgment() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                print("\(user.uid) login")
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
}
