//
//  SignInVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/15.
//

import UIKit
import FirebaseAuth

class SignInVC: UIViewController {
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        topBackgroundView.layer.cornerRadius = 20
    }
    
    @IBAction func dismissPage(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func logIn(_ sender: Any) {
        if
            let email = emailTextField.text,
            let password = passwordTextField.text,
            email.isEmpty || password.isEmpty {
            showAlert(title: "未填寫完整", message: "請輸入Email和密碼")
        } else {
            guard
                let email = emailTextField.text,
                let password = passwordTextField.text else { return }
            Auth.auth().signIn(withEmail: email, password: password) { _, error in
                if error != nil {
                    self.showAlert(title: "登入失敗", message: "請重新嘗試")
                } else {
                    self.view.window?.rootViewController?.dismiss(animated: true)
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.emailTextField.text = ""
            self?.passwordTextField.text = ""
        }
        
        controller.addAction(alertAction)
        present(controller, animated: true)
    }
}
