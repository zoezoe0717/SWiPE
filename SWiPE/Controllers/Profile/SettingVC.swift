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
    @IBOutlet weak var tableView: UITableView!
    
    private let settingOptions = ["修改暱稱", "修改自我介紹", "修改年齡", "查看隱私權政策", "刪除帳號", "登出"]
    
    private let actions = [
        #selector(editUserName),
        #selector(editUserIntroduction),
        #selector(editUserAge),
        #selector(presentPrivacyPage),
        #selector(deleteAccount),
        #selector(signOut)
    ]
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationController?.navigationBar.isHidden = false
        let newBackButton = UIBarButtonItem(
            title: "",
            style: UIBarButtonItem.Style.plain,
            target: self,
            action: #selector(dismissPage)
        )
        newBackButton.image = UIImage(systemName: "chevron.backward")
        
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @objc private func editUserAge() {
        let message = AlertMessage(
            text: "您要更新年齡嗎？",
            successSubTitle: "更新成功",
            errorSubTitle: "您尚未輸入年齡喔！",
            alertTitle: "更新年齡",
            alertSubTitle: "請在下方輸入您的年齡"
        )
        guard let user = user else { return }
        ZAlertView.shared.editView(message: message, user: user, dataType: "age")
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
        let controller = UIAlertController(title: "確定要登出帳號嗎？", message: "登出後下次需重新登入", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "登出", style: .destructive) { [weak self] _ in
            do {
                try Auth.auth().signOut()
            } catch {
                print(error)
            }
            UserUid.share.setUidKeychain(uid: "")
            self?.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(action)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    @objc private func deleteAccount() {
        let controller = UIAlertController(title: "確定要刪除帳號嗎？", message: "刪除帳號後，將無法復原。", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "刪除", style: .destructive) { [weak self] _ in
            ProgressHUD.show()
            Auth.auth().currentUser?.delete()
            FireBaseManager.shared.deleteUser()
            ProgressHUD.dismiss()
            ZSwiftJWT.share.removeAccount()
            
            ProgressHUD.dismiss()
            self?.dismissPage()
            self?.signOut()
        }
    
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(action)
        controller.addAction(cancelAction)
        present(controller, animated: true)
    }
    
    @objc private func dismissPage() {
        self.navigationController?.popViewController(animated: true)
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
//        if let url = URL(string: "https://www.privacypolicies.com/live/739f8e31-8ddf-4b6b-8ba2-0c4bcba24a63") {
//            let safari = SFSafariViewController(url: url)
//            safari.delegate = self
//            present(safari, animated: true)
//        }
        
        if let controller = storyboard?.instantiateViewController(withIdentifier: "\(PrivacyPolicyVC.self)") as? PrivacyPolicyVC {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
