//
//  SignVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/16.
//

import UIKit
import Lottie

class SignVC: UIViewController {
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var signupLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupStackView: UIStackView!
    
    private lazy var signCatAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: LottieString.signCat.rawValue)
        view.contentMode = .scaleAspectFill
        view.loopMode = .loop
        view.play()
        
        return view
    }()
    
    private lazy var arrowAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: LottieString.arrow.rawValue)
        view.contentMode = .scaleAspectFill
        view.loopMode = .loop
        view.play()
        
        return view
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundView()
        setConstraints()
        setUI()
    }
    
    private func setUI() {
        welcomeLabel.text = SignVCString.welcome.rawValue
        signupLabel.text = SignVCString.signup.rawValue

        loginButton.setTitle(SignVCString.login.rawValue, for: .normal)
        loginButton.layer.cornerRadius = loginButton.bounds.width * 0.03
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSignUpPage))
        signupStackView.addGestureRecognizer(tap)
    }
    
    private func setConstraints() {
        [signCatAnimationView, arrowAnimationView].forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(signCatAnimationView)
        NSLayoutConstraint.activate([
            signCatAnimationView.centerXAnchor.constraint(equalTo: topBackgroundView.centerXAnchor),
            signCatAnimationView.centerYAnchor.constraint(equalTo: topBackgroundView.centerYAnchor),
            signCatAnimationView.widthAnchor.constraint(equalTo: topBackgroundView.widthAnchor, multiplier: 0.6),
            signCatAnimationView.heightAnchor.constraint(equalTo: topBackgroundView.widthAnchor, multiplier: 0.6)
        ])
        
        signupStackView.addArrangedSubview(arrowAnimationView)
        NSLayoutConstraint.activate([
            arrowAnimationView.heightAnchor.constraint(equalTo: signupLabel.heightAnchor),
            arrowAnimationView.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setBackgroundView() {
        topBackgroundView.layer.maskedCorners = .layerMaxXMaxYCorner
        bottomBackgroundView.layer.maskedCorners = .layerMinXMinYCorner
        
        [topBackgroundView, bottomBackgroundView].forEach { subView in
            subView.layer.cornerRadius = 60
        }
    }
    
    @objc private func showSignUpPage() {
        print("===skosko")
    }
}
