//
//  AuthManager.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/24.
//

import UIKit
import Alamofire

class AuthManager {
    static let share = AuthManager()
    
    let teamId = "3ZZ46LG3G3"
    let digitalCertificate =
        """
        -----BEGIN PRIVATE KEY-----
        MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgsuQyCJvX+N6NIgC4
        4N7SlJkt84OfuzIzFvfU8YB1amCgCgYIKoZIzj0DAQehRANCAASu0lQsh887YwVl
        u5c6idwyc5JNV3SjNPmBrRefFWyE90KKIRmX3C9T3iFhflUjJL0l6FKlVvbtJViT
        hTPiJ2In
        -----END PRIVATE KEY-----
        """
    let appleId = "FHH82V8NXD"
    let aud = "https://appleid.apple.com"
    let claimsId = "com.zoe.SWiPE"
    
    func fetchTokenInfo(params: [String: String]) {
        let headers: HTTPHeaders = ["content-type": "application/x-www-form-urlencoded"]

        AF.request("https://appleid.apple.com/auth/token", method: .post, parameters: params, headers: headers).response { reponse in
            let decoder = JSONDecoder()
            if let result = reponse.data,
                let token = try? decoder.decode(AppleAuthToken.self, from: result) {
                
                UserUid.share.keychain.set(token.refreshToken, forKey: "refreshToken")
                }
        }
    }
    
    func removeAccount(params: [String: String]) {
        let token = UserUid.share.keychain.get("refreshToken")
        
        let headers: HTTPHeaders = ["content-type": "application/x-www-form-urlencoded"]

        AF.request("https://appleid.apple.com/auth/revoke", method: .post, parameters: params, headers: headers).response { response in
            if response.response?.statusCode == 200 {
                print("SUCCESS!")
            }
        }
    }
}

struct AppleAuthToken: Codable {
    let accessToken, tokenType: String
    let expiresIn: Int
    let refreshToken, idToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case idToken = "id_token"
    }
}
