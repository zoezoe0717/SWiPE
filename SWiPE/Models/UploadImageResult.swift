//
//  UploadImageResult.swift
//  SWiPE
//
//  Created by Zoe on 2022/12/2.
//

import Foundation

struct UploadImageResult: Decodable {
    let data: UploadData
}

struct UploadData: Decodable {
    let link: URL
}
