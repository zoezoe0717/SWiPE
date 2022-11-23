//
//  PrivacyVC.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/23.
//

import UIKit
import WebKit

class PrivacyVC: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    
    private var observation: NSKeyValueObservation?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setWebView()
    }
    
    deinit {
        observation = nil
    }
    
    private func setBackButton() {
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "", style: UIBarButtonItem.Style.plain, target: self, action: #selector(dissmidPage))
        newBackButton.image = UIImage(systemName: "chevron.backward")
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    private func setWebView() {
        progressView.progress = 0
        guard let url = URL(string: "https://www.privacypolicies.com/live/739f8e31-8ddf-4b6b-8ba2-0c4bcba24a63") else { return }
        
        self.webView.load(NSURLRequest(url: url) as URLRequest)
        
        observation = webView.observe(\.estimatedProgress, options: [.new]) { _, _ in
            self.progressView.progress = Float(self.webView.estimatedProgress)
        }
    }
    
    @objc private func dissmidPage() {
        dismiss(animated: true)
    }
}
