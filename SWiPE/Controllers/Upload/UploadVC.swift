//
//  UploadVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/10.
//

import UIKit

class UploadVC: UIViewController {
    lazy var isNewUser = true
    
    lazy var createButton: UIButton = {
        let button = UIButton()
        button.setTitle("點我新增", for: .normal)
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        return button
    }()
    
    lazy public var pushButton: UIButton = {
        let button = UIButton()
        button.setTitle("確定", for: .normal)
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(uploadData), for: .touchUpInside)
        return button
    }()
    
    lazy public var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("重新選擇", for: .normal)
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = CustomColor.base.color
    }
    
    public func buttonSwitch(hasImage: Bool) {
        if hasImage {
            createButton.isHidden = true
            pushButton.isHidden = false
            cancelButton.isHidden = false
        } else {
            createButton.isHidden = false
            pushButton.isHidden = true
            cancelButton.isHidden = true
        }
    }
    
    public func createCamera() {
    }

    @objc public func openCamera() {
        createCamera()
    }
        
    @objc public func uploadData() {
        print("上傳")
    }
}
