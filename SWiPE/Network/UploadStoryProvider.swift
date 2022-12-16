//
//  UploadProvider.swift
//  SWiPE
//
//  Created by Zoe on 2022/10/31.
//

import Foundation
import Firebase
import Alamofire
import AVFoundation

class UploadStoryProvider {
    static let shared = UploadStoryProvider()
    
    func uploadImageWithImgur(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        let headers: HTTPHeaders = ["Authorization": "Client-ID 977f389688519a1"]
        let urlString = "https://api.imgur.com/3/image"
        
        AF.upload(multipartFormData: { data in
            guard let imageData = image.jpegData(compressionQuality: 0.9) else { return }
            data.append(imageData, withName: "image")
        }, to: urlString,
            headers: headers)
        .responseDecodable(of: UploadImageResult.self, decoder: JSONDecoder()) { response in
            switch response.result {
            case .success(let result):
                completion(.success("\(result.data.link)"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func uploadVideoWithImgur(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Client-ID 977f389688519a1"
        ]
        
        let urlString = "https://api.imgur.com/3/upload"
        
        AF.upload(multipartFormData: { data in
            data.append(url, withName: "video", fileName: "video.mov", mimeType: "video/mov")
        }, to: urlString,
            method: .post,
            headers: headers)
        .responseDecodable(of: UploadImageResult.self, decoder: JSONDecoder()) { response in
            switch response.result {
            case .success(let result):
                completion(.success(result.data.link))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
