//
//  MatchSuccessVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/4.
//

import UIKit
import Lottie

class MatchSuccessVC: UIViewController {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var goToChatButton: UIButton!
    @IBOutlet weak var continueMatchButton: UIButton!
    var needToPlay: ((Bool) -> Void)?
    var userImageString: String?
    var friendImageString: String?
    
    lazy private var matchAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: LottieString.match.rawValue)
        view.contentMode = .scaleAspectFit
        view.play()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        userImageView.loadImage(userImageString)
        friendImageView.loadImage(friendImageString)
        
        [userImageView, friendImageView, goToChatButton, continueMatchButton].forEach { view in
            view?.layer.cornerRadius = (view?.frame.width ?? 100) * 0.05
        }
        
        view.addSubview(matchAnimationView)
        matchAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            matchAnimationView.topAnchor.constraint(equalTo: userImageView.topAnchor, constant: 20),
            matchAnimationView.bottomAnchor.constraint(equalTo: friendImageView.bottomAnchor, constant: 20),
            matchAnimationView.leftAnchor.constraint(equalTo: view.leftAnchor),
            matchAnimationView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    @IBAction func dismissPage(_ sender: Any) {
        needToPlay?(true)
        if let tabBar = presentingViewController as? SwipeTabBarController {
            tabBar.selectedIndex = 0
        }
        dismiss(animated: true)
    }
    
    @IBAction func goToChatPage(_ sender: Any) {
        if let tabBar = presentingViewController as? SwipeTabBarController {
            tabBar.selectedIndex = 1
        }
        dismiss(animated: true)
    }
}
