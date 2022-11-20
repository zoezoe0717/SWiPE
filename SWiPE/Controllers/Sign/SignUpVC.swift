//
//  SignUpVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/16.
//

import UIKit
import Lottie
import CryptoKit
import FirebaseAuth
import AuthenticationServices


class SignUpVC: UIViewController {
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var nextPageButton: UIButton!
    
    var userData: User?
    
    lazy private var arrowAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: LottieString.arrow.rawValue)
        view.transform = CGAffineTransform(scaleX: -1, y: 1)
        view.loopMode = .loop
        view.contentMode = .scaleAspectFill
        view.play()
        
        return view
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundView()
        setButton()
    }
    
    private func setBackgroundView() {
        topBackgroundView.layer.maskedCorners = .layerMinXMaxYCorner
        bottomBackgroundView.layer.maskedCorners = .layerMaxXMinYCorner
        
        [topBackgroundView, bottomBackgroundView].forEach { $0?.layer.cornerRadius = 60 }
    }
    
    private func setButton() {
        [arrowAnimationView].forEach { button in
            view.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(arrowAnimationView)
        arrowAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backSignPage))
        arrowAnimationView.addGestureRecognizer(tap)
        
        NSLayoutConstraint.activate([
            arrowAnimationView.heightAnchor.constraint(equalTo: topBackgroundView.widthAnchor, multiplier: 0.2),
            arrowAnimationView.widthAnchor.constraint(equalTo: topBackgroundView.widthAnchor, multiplier: 0.2),
            arrowAnimationView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            arrowAnimationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25)
        ])
    }
    
    private func addNewUser(with user: inout User) {
        FireBaseManager.shared.addUser(user: &user) { result in
            switch result {
            case .success(let message):
                print(message)
            case .failure(let error):
                print("DEBUG: \(error)")
            }
        }
    }
   
    
    @objc private func backSignPage() {
        dismiss(animated: true)
    }
    
    @IBAction func presentNextPage(_ sender: Any) {
        guard let name = nameTextField.text,
            let age = ageTextField.text else { return }
        
        guard !name.isEmpty && !age.isEmpty else {
            print("尚未輸入完整")
            return
        }
        
        SignVC.userData.name = name
        SignVC.userData.age = Int(age) ?? 0
        addNewUser(with: &SignVC.userData)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "\(UploadPhotoVC.self)") as? UploadPhotoVC {
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        }
    }
}
