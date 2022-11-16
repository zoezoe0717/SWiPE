//
//  UploadProvider.swift
//  SWiPE
//
//  Created by Zoe on 2022/10/31.
//

import Foundation
import Firebase

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
