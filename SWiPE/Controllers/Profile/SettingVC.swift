//
//  SettingVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/23.
//

import UIKit
import Lottie
import FirebaseAuth
import SafariServices

class SettingVC: UIViewController {
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private let settingOptions = ["修改暱稱", "修改自我介紹", "查看隱私權政策", "刪除帳號", "登出"]
    
    private let actions = [
        #selector(editUserName),
        #selector(editUserIntroduction),
        #selector(presentPrivacyPage),
        #selector(deleteAccount),
        #selector(signOut)
    ]
    
    var user: User?
    
    private lazy var sheepAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: Constants.LottieString.swimmingSheep)
        view.contentMode = .scaleAspectFill
        view.loopMode = .loop
        view.play()
        
        return view
    }()
    
    lazy private var arrowAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: Constants.LottieString.arrow)
        view.transform = CGAffineTransform(scaleX: -1, y: 1)
        view.loopMode = .loop
        view.contentMode = .scaleAspectFill
        view.play()
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPage))
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        [sheepAnimationView, arrowAnimationView].forEach { $0.play() }
    }
    
    private func setUI() {
        bottomBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bottomBackgroundView.layer.cornerRadius = view.bounds.size.width * 0.2
        
        topBackgroundView.addSubview(sheepAnimationView)
        view.addSubview(arrowAnimationView)

        [sheepAnimationView, arrowAnimationView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            sheepAnimationView.topAnchor.constraint(equalTo: topBackgroundView.topAnchor),
            sheepAnimationView.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor),
            sheepAnimationView.leftAnchor.constraint(equalTo: topBackgroundView.leftAnchor),
            sheepAnimationView.rightAnchor.constraint(equalTo: topBackgroundView.rightAnchor),
            
            arrowAnimationView.heightAnchor.constraint(equalTo: topBackgroundView.widthAnchor, multiplier: 0.2),
            arrowAnimationView.widthAnchor.constraint(equalTo: topBackgroundView.widthAnchor, multiplier: 0.2),
            arrowAnimationView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            arrowAnimationView.topAnchor.constraint(equalTo: view.topAnchor, constant: 25)
        ])
    }
    
    @objc private func editUserName() {
        let message = AlertMessage(
            text: "您的新名字是？",
            successSubTitle: "成功更新您的暱稱",
            errorSubTitle: "您尚未輸入新暱稱喔！",
            alertTitle: "更新暱稱",
            alertSubTitle: "請在下方輸入您的新暱稱"
        )
        guard let user = user else { return }
        ZAlertView.shared.editView(message: message, user: user, dataType: "name")
    }
    
    @objc private func editUserIntroduction() {
        let message = AlertMessage(
            text: "您要更新自我介紹嗎？",
            successSubTitle: "更新成功",
            errorSubTitle: "您尚未輸入自我介紹喔！",
            alertTitle: "更新自我介紹",
            alertSubTitle: "請在下方輸入您的自我介紹"
        )
        guard let user = user else { return }
        ZAlertView.shared.editView(message: message, user: user, dataType: "introduction")
    }
    
    @objc private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        UserUid.share.setUidKeychain(uid: "")
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func deleteAccount() {
        ProgressHUD.show()
        Auth.auth().currentUser?.delete()
        FireBaseManager.shared.deleteUser()
        ProgressHUD.dismiss()
        ZSwiftJWT.share.removeAccount()
        
        ProgressHUD.dismiss()
        dismissPage()
        signOut()
    }
    
    @objc private func dismissPage() {
        dismiss(animated: true)
    }
}

extension SettingVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 61.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(SettingCell.self)", for: indexPath) as? SettingCell else { fatalError("DEBUG: Create SettingCell Error") }
        
        let tap = UITapGestureRecognizer(target: self, action: actions[indexPath.item])
        cell.cardBackgroundView.addGestureRecognizer(tap)
        
        cell.titleLabel.text = settingOptions[indexPath.item]
        return cell
    }
}

extension SettingVC: SFSafariViewControllerDelegate {
    @objc func presentPrivacyPage() {
        if let url = URL(string: "https://www.privacypolicies.com/live/739f8e31-8ddf-4b6b-8ba2-0c4bcba24a63") {
            let safari = SFSafariViewController(url: url)
            safari.delegate = self
            present(safari, animated: true)
        }
    }
}
