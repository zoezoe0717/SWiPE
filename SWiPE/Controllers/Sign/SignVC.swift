//
//  SignVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/16.
//

import UIKit
import Lottie
import CryptoKit
import FirebaseAuth
import AuthenticationServices

class SignVC: UIViewController {
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    private var currentNonce: String?
    
    private lazy var signCatAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: LottieString.signSheep.rawValue)
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
    
    private lazy var signInAppleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
        button.cornerRadius = 10
        button.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        
        return button
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundView()
        setConstraints()
        setUI()
        getFirebaseUserInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        [signCatAnimationView, arrowAnimationView].forEach { $0.play() }
    }
    
    private func setUI() {
        welcomeLabel.text = SignVCString.welcome.rawValue
    }
    
    private func setConstraints() {
        [welcomeLabel, signCatAnimationView, signInAppleButton].forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subView)
        }
        
        NSLayoutConstraint.activate([
            signCatAnimationView.topAnchor.constraint(equalTo: topBackgroundView.topAnchor),
            signCatAnimationView.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor),
            signCatAnimationView.leftAnchor.constraint(equalTo: topBackgroundView.leftAnchor),
            signCatAnimationView.rightAnchor.constraint(equalTo: topBackgroundView.rightAnchor),
            
            signInAppleButton.centerYAnchor.constraint(equalTo: bottomBackgroundView.centerYAnchor),
            signInAppleButton.centerXAnchor.constraint(equalTo: bottomBackgroundView.centerXAnchor),
            signInAppleButton.widthAnchor.constraint(equalTo: bottomBackgroundView.widthAnchor, multiplier: 0.8),
            signInAppleButton.heightAnchor.constraint(equalTo: bottomBackgroundView.heightAnchor, multiplier: 0.15),
            
            welcomeLabel.leftAnchor.constraint(equalTo: signInAppleButton.leftAnchor),
            welcomeLabel.topAnchor.constraint(equalTo: bottomBackgroundView.topAnchor, constant: 40)
        ])
    }
    
    private func setBackgroundView() {
        topBackgroundView.layer.maskedCorners = .layerMaxXMaxYCorner
        bottomBackgroundView.layer.maskedCorners = .layerMinXMinYCorner
        signCatAnimationView.layer.maskedCorners = .layerMaxXMaxYCorner
        
        [topBackgroundView, bottomBackgroundView, signCatAnimationView].forEach { $0.layer.cornerRadius = 60 }
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
    
    @objc private func signInWithApple() {
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
extension SignVC: ASAuthorizationControllerDelegate {
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
extension SignVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = view.window else { fatalError("DEBUG: view.window is nil!") }
        return window
    }
}

extension SignVC {
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
