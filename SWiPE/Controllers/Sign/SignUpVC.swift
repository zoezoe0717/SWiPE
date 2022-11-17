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
    
    lazy private var arrowAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: LottieString.arrow.rawValue)
        view.transform = CGAffineTransform(scaleX: -1, y: 1)
        view.loopMode = .loop
        view.contentMode = .scaleAspectFill
        view.play()
        
        return view
    }()
    
    lazy private var signUpAppleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signUp, authorizationButtonStyle: .black)
        button.cornerRadius = 10
        button.addTarget(self, action: #selector(signUpWithApple), for: .touchUpInside)
        
        return button
    }()
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeAppleIDSessionChanges()
        setBackgroundView()
        setButton()
    }
    
    private func setBackgroundView() {
        topBackgroundView.layer.maskedCorners = .layerMinXMaxYCorner
        bottomBackgroundView.layer.maskedCorners = .layerMaxXMinYCorner
        
        [topBackgroundView, bottomBackgroundView].forEach { $0?.layer.cornerRadius = 60 }
    }
    
    private func setButton() {
        [arrowAnimationView, signUpAppleButton].forEach { button in
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
            arrowAnimationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            signUpAppleButton.widthAnchor.constraint(equalTo: bottomBackgroundView.widthAnchor, multiplier: 0.7),
            signUpAppleButton.heightAnchor.constraint(equalToConstant: 50),
            signUpAppleButton.centerXAnchor.constraint(equalTo: bottomBackgroundView.centerXAnchor),
            signUpAppleButton.centerYAnchor.constraint(equalTo: bottomBackgroundView.centerYAnchor, constant: -50)
        ])
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randows: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                
                if errorCode != errSecSuccess {
                    fatalError("DEBUG: Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randows.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }
            .joined()
        
        return hashString
    }
    
    private func observeAppleIDSessionChanges() {
        NotificationCenter.default.addObserver(forName: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil, queue: nil) { notification in
            print("===WW\(notification)")
        }
    }
    
    @objc private func backSignPage() {
        dismiss(animated: true)
    }
    
    @objc private func signUpWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// MARK: ASAuthorizationControllerDelegate
extension SignUpVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // 登入成功
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                return
            }
            // 產生 Apple ID 登入的 Credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            // 與 Firebase Auth 進行串接
            firebaseSignInWithApple(credential: credential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 登入失敗，處理 Error
        switch error {
        case ASAuthorizationError.canceled:
            print("使用者取消登入")
        case ASAuthorizationError.failed:
            print("授權請求失敗")
        case ASAuthorizationError.invalidResponse:
            print("授權請求無回應")
        case ASAuthorizationError.notHandled:
            print("授權請求未處理")
        case ASAuthorizationError.unknown:
            print("授權失敗，原因不知")
        default:
            break
        }
    }
}

// MARK: ASAuthorizationControllerPresentationContextProviding
extension SignUpVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = view.window else { fatalError("DEBUG: view.window is nil!") }
        return window
    }
}

extension SignUpVC {
    // MARK: 透過 Credential 與 Firebase Auth 串接
    func firebaseSignInWithApple(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            guard error == nil else { return }
            print("===EE\(authResult)")
            print("登入成功！")
        }
    }
    
    // MARK: Firebase 取得登入使用者的資訊
    func getFirebaseUserInfo() {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else {
            fatalError("Can not find user information")
        }
        let uid = user.uid
        let email = user.email
        
        print("===\(uid)")
        print("===A\(email)")
    }
    
    func checkAppleIDCredentialState(userID: String) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { credentialState, error in
            switch credentialState {
            case .authorized:
                print("使用者已授權！")
            case .revoked:
                print("使用者憑證已被註銷")
            case .notFound:
                print("使用者尚未使用過 Apple ID 登入")
            case .transferred:
                print("請與開發者團隊進行聯繫，以利進行使用者遷移")
            default:
                break
            }
        }
    }
}
