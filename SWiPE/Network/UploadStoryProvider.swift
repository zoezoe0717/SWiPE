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
    
    func uploadPhoto(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileReference = Storage.storage().reference().child(UUID().uuidString + ".jpg")
        if let data = image.jpegData(compressionQuality: 0.1) {
            fileReference.putData(data, metadata: nil) { result in
                switch result {
                case .success:
                    fileReference.downloadURL(completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func uploadVideo(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let videoName = NSUUID().uuidString
        let fileReference = Storage.storage().reference().child("\(videoName).mov")
        
        fileReference.putFile(from: url, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                fileReference.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        if let url = url {
                            completion(.success(url))
                        }
                    }
                }
            }
        }
    }
}

struct UploadImageResult: Decodable {
    struct Data: Decodable {
        let link: URL
    }
    let data: Data
}

extension UploadStoryProvider {
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
    
    
    func uploadVideoWithImgur(url: URL) {
        let boundary = UUID().uuidString
        let session = URLSession.shared
        var data = Data()

        guard let movData = try? Data(contentsOf: url) else { return }
        let headers: HTTPHeaders = ["Authorization": "Client-ID 977f389688519a1"]
        let parameters = ["video": movData]
        let urlString = "https://api.imgur.com/3/upload"
        
        AF.upload(multipartFormData: { data in
            data.append(url, withName: "video", fileName: "video.mov", mimeType: "video/mov")
        }, to: urlString,
            method: .post,
            headers: headers)
        .responseDecodable(of: UploadImageResult.self, decoder: JSONDecoder()) { response in
            switch response.result {
            case .success(let result):
                print("---->>>>\(result.data.link)")
            case .failure(let error):
                print(error)
            }
        }
    }
}
