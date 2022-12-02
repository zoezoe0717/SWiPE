//
//  Upload.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/2.
//

import Foundation

struct UploadImageResult: Decodable {
    let data: Data
}

struct Data: Decodable {
    let link: URL
}
