//
//  SettingVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/23.
//

import UIKit
import Lottie
import FirebaseAuth

class SettingVC: UIViewController {
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private let settingOptions = ["修改暱稱", "修改自我介紹", "查看隱私權政策", "刪除帳號", "登出"]
    private let actions = [#selector(test), #selector(test), #selector(test), #selector(test), #selector(signOut)]
    
    private lazy var sheepAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: LottieString.swimmingSheep.rawValue)
        view.contentMode = .scaleAspectFill
        view.loopMode = .loop
        view.play()
        
        return view
    }()
    
    lazy private var arrowAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: LottieString.arrow.rawValue)
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
    
    @objc func test() {
        print("dkdkd")
    }
    
    @objc func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        UserUid.share.setUidKeychain(uid: "")
        
        dismiss(animated: true)
    }
}
