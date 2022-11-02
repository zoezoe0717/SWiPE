//
//  KingFisherWrapper.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/1.
//

import Foundation
import Kingfisher

extension UIImageView {
    func loadImage(_ urlString: String?) {
        guard urlString != nil else { return }
        if let urlString = urlString {
            let url = URL(string: urlString)
            self.kf.setImage(with: url)
        }
    }
}
