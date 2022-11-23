//
//  SettingVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/23.
//

import UIKit
import Lottie

class SettingVC: UIViewController {
    @IBOutlet weak var bottomBackgroundView: UIView!
    @IBOutlet weak var topBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private let settingOptions = ["修改暱稱", "修改自我介紹", "查看隱私權政策", "刪除帳號", "登出"]
    
    private lazy var sheepAnimationView: LottieAnimationView = {
        let view = LottieAnimationView(name: LottieString.swimmingSheep.rawValue)
        view.contentMode = .scaleAspectFill
        view.loopMode = .loop
        view.play()
        
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
        sheepAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sheepAnimationView.topAnchor.constraint(equalTo: topBackgroundView.topAnchor),
            sheepAnimationView.bottomAnchor.constraint(equalTo: topBackgroundView.bottomAnchor),
            sheepAnimationView.leftAnchor.constraint(equalTo: topBackgroundView.leftAnchor),
            sheepAnimationView.rightAnchor.constraint(equalTo: topBackgroundView.rightAnchor)
        ])
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
        
        cell.titleLabel.text = settingOptions[indexPath.item]
        return cell
    }
}
