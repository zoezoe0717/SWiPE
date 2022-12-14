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
    static var userData =
    User(
        id: UserUid.share.getUid(),
        name: "",
        email: "",
        latitude: 0,
        longitude: 0,
        age: 0,
        story: "",
        video: "",
        introduction: "",
        createdTime: 0,
        index: ""
    )
    
    @IBOutlet weak var signInStackView: UIStackView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var subTitleTextView: UITextView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    private var currentNonce: String?
    var userName: String?
    
    private lazy var signCatAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: Constants.LottieString.signSheep)
        view.contentMode = .scaleAspectFill
        view.loopMode = .loop
        view.play()
        
        return view
    }()
    
    private lazy var arrowAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: Constants.LottieString.arrow)
        view.contentMode = .scaleAspectFill
        view.loopMode = .loop
        view.play()
        
        return view
    }()
    
    private lazy var signInAppleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .whiteOutline)
        button.cornerRadius = 10
        button.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var signInEmailButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = .black
        button.setTitle("Sign in with Email", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(signInWithEmail), for: .touchUpInside)
        
        return button
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundView()
        setConstraints()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        [signCatAnimationView, arrowAnimationView].forEach { $0.play() }
    }
    
    private func setUI() {
        welcomeLabel.textColor = CustomColor.text.color
        welcomeLabel.text = Constants.SignVCString.welcome
        
        let attributedString = NSMutableAttributedString(
            string: Constants.SignVCString.subTitle,
            attributes: [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: CustomColor.text.color
            ]
        )
        
        attributedString.addAttribute(
            .link,
            value: "https://privacy-policy-iwn932vpl-zoezoe0717.vercel.app",
            range: NSRange(location: 14, length: 3)
        )

        subTitleTextView.attributedText = attributedString
    }
    
    private func setConstraints() {
        [welcomeLabel, subTitleTextView, signCatAnimationView, signInStackView].forEach { subView in
            subView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(subView)
        }
        
        [signInAppleButton, signInEmailButton].forEach { button in
            button.translatesAutoresizingMaskIntoConstraints = false
            signInStackView.addSubview(button)
        }
        
        NSLayoutConstraint.activate([
            signCatAnimationView.topAnchor.constraint(equalTo: topBackgroundView.topAnchor),
            signCatAnimationView.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor),
            signCatAnimationView.leftAnchor.constraint(equalTo: topBackgroundView.leftAnchor),
            signCatAnimationView.rightAnchor.constraint(equalTo: topBackgroundView.rightAnchor),
            
            signInStackView.centerXAnchor.constraint(equalTo: bottomBackgroundView.centerXAnchor),
            signInStackView.leftAnchor.constraint(equalTo: bottomBackgroundView.leftAnchor, constant: 20),
            signInStackView.rightAnchor.constraint(equalTo: bottomBackgroundView.rightAnchor, constant: -20),
            signInStackView.heightAnchor.constraint(equalTo: bottomBackgroundView.heightAnchor, multiplier: 0.4),
            
            signInEmailButton.widthAnchor.constraint(equalTo: bottomBackgroundView.widthAnchor, multiplier: 0.8),
            signInEmailButton.heightAnchor.constraint(equalTo: bottomBackgroundView.heightAnchor, multiplier: 0.15),
            signInEmailButton.topAnchor.constraint(equalTo: signInAppleButton.bottomAnchor, constant: 10),
            signInEmailButton.centerXAnchor.constraint(equalTo: signInStackView.centerXAnchor),
            
            signInAppleButton.widthAnchor.constraint(equalTo: bottomBackgroundView.widthAnchor, multiplier: 0.8),
            signInAppleButton.heightAnchor.constraint(equalTo: bottomBackgroundView.heightAnchor, multiplier: 0.15),
            signInAppleButton.centerXAnchor.constraint(equalTo: signInStackView.centerXAnchor),
            
            welcomeLabel.leftAnchor.constraint(equalTo: signInAppleButton.leftAnchor),
            welcomeLabel.topAnchor.constraint(equalTo: bottomBackgroundView.topAnchor, constant: 40),
            
            subTitleTextView.leftAnchor.constraint(equalTo: signInAppleButton.leftAnchor),
            subTitleTextView.bottomAnchor.constraint(equalTo: signInAppleButton.topAnchor, constant: -10),
            subTitleTextView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 10),
            subTitleTextView.heightAnchor.constraint(equalToConstant: 30),
            subTitleTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 10)
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
    
    private func addActionController(compltion: @escaping () -> ()) {
        let controller = UIAlertController(title: "?????????????????????", message: "????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "??????", style: .default) { _ in
            compltion()
        }
        let cancelAction = UIAlertAction(title: "????????????", style: .cancel)
        [alertAction, cancelAction].forEach { controller.addAction($0) }
        present(controller, animated: true)
    }
    
    @objc private func signInWithApple() {
        addActionController {
            let nonce = self.randomNonceString()
            self.currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = self.sha256(nonce)

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
    @objc private func signInWithEmail() {
        addActionController {
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "\(SignInVC.self)") as? SignInVC {
                self.present(controller, animated: true)
            }
        }
    }
}

// MARK: ASAuthorizationControllerDelegate
extension SignVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // ????????????
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
            
            if
                let userFullName = appleIDCredential.fullName,
                let userGiveName = userFullName.givenName {
                userName = userGiveName
            }
            // ?????? Apple ID ????????? Credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            // ??? Firebase Auth ????????????
            firebaseSignInWithApple(credential: credential)

            // Add new code below
            if
                let authorizationCode = appleIDCredential.authorizationCode,
                let codeString = String(data: authorizationCode, encoding: .utf8) {
                ZSwiftJWT.share.getRefreshToken(codeString)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // ????????????????????? Error
        switch error {
        case ASAuthorizationError.canceled:
            print("?????????????????????")
        case ASAuthorizationError.failed:
            print("??????????????????")
        case ASAuthorizationError.invalidResponse:
            print("?????????????????????")
        case ASAuthorizationError.notHandled:
            print("?????????????????????")
        case ASAuthorizationError.unknown:
            print("???????????????????????????")
        default:
            break
        }
    }
}

// MARK: ASAuthorizationControllerPresentationContextProviding
extension SignVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = view.window else {
            fatalError("DEBUG: view.window is nil!")
        }
        return window
    }
}

extension SignVC {
    // MARK: ?????? Credential ??? Firebase Auth ??????
    func firebaseSignInWithApple(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] _, error in
            guard error == nil else { return }
            print("???????????????")
            self?.getFirebaseUserInfo()
        }
    }
    
    // MARK: Firebase ??????????????????????????????
    func getFirebaseUserInfo() {
        let currentUser = Auth.auth().currentUser
        guard let currentUser = currentUser else {
            fatalError("Can not find user information")
        }
        UserUid.share.setUidKeychain(uid: currentUser.uid)
        SignVC.userData.id = currentUser.uid
        signUpJudgment(uid: currentUser.uid)
    }
    
    private func signUpJudgment(uid: String) {
        FireBaseManager.shared.searchUserDocument(uid: uid) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let user):
                if let user = user {
                    self.userDataCheck(user: user)
                } else {
                    self.presentSignUpVC()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func userDataCheck(user: User) {
        if user.name.isEmpty || user.age == 0 {
            presentSignUpVC()
        } else if user.story.isEmpty {
            presentUploadPhoto()
        } else if user.video.isEmpty {
            presentUploadVideo()
        } else {
            dismiss(animated: true)
        }
    }
        
    private func presentSignUpVC() {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "\(SignUpVC.self)") as? SignUpVC {
            controller.modalPresentationStyle = .fullScreen
            if let userName = userName {
                controller.userName = userName
            }
            present(controller, animated: true)
        }
    }
    
    private func presentUploadPhoto() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(
            withIdentifier: "\(UploadPhotoVC.self)") as? UploadPhotoVC {
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        }
    }
    
    private func presentUploadVideo() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(
            withIdentifier: "\(UploadVideoVC.self)") as? UploadVideoVC {
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        }
    }
}
