//
//  SwipeTabBarController.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/13.
//

import UIKit
import FirebaseAuth

class SwipeTabBarController: UITabBarController, UITabBarControllerDelegate {
    lazy var customView: UIView = {
        let view = UIView()
        view.backgroundColor = CustomColor.main.color
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 20

        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = CustomColor.secondary.color
//        clearLogin()
        loginJudgment()
        setUI()
    }
    
    private func setUI() {
        self.tabBar.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            customView.centerYAnchor.constraint(equalTo: self.tabBar.centerYAnchor),
            customView.centerXAnchor.constraint(equalTo: self.tabBar.centerXAnchor),
            customView.bottomAnchor.constraint(equalTo: self.tabBar.bottomAnchor),
            customView.topAnchor.constraint(equalTo: self.tabBar.topAnchor),
            customView.bottomAnchor.constraint(equalTo: self.tabBar.bottomAnchor),
            customView.widthAnchor.constraint(equalTo: self.tabBar.widthAnchor, multiplier: 1),
            customView.heightAnchor.constraint(equalTo: self.tabBar.heightAnchor, multiplier: 1)
        ])
    }
    
    private func clearLogin() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
    
    private func loginJudgment() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user = user {
                print("\(user.uid) Login")
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
