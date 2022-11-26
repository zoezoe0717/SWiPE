//
//  SwiftJWTWrapper.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/24.
//

import SwiftJWT

class ZSwiftJWT {
    static let share = ZSwiftJWT()
    
    func getRefreshToken(_ authorizationCode: String) {
        let header = Header(kid: AuthManager.share.teamId)
        
        let claims = AuthClaims(
            iss: AuthManager.share.appleId,
            iat: Date(),
            exp: Date(timeIntervalSinceNow: 3600),
            aud: AuthManager.share.aud,
            sub: AuthManager.share.claimsId
        )
        
        var jwt = JWT(header: header, claims: claims)
        
        let jwtSigner = JWTSigner.es256(privateKey: Data(AuthManager.share.digitalCertificate.utf8))
        
        do {
            let signedJWT = try jwt.sign(using: jwtSigner)
            print("===---\(signedJWT)")
            
            let params = [
                "client_id": AuthManager.share.claimsId,
                "client_secret": signedJWT,
                "code": authorizationCode,
                "grant_type": "authorization_code"
            ]
            
            AuthManager.share.fetchTokenInfo(params: params)
        } catch {
            print(error)
        }
    }
    
    func removeAccount() {
        let header = Header(kid: AuthManager.share.teamId)
        
        let claims = AuthClaims(
            iss: AuthManager.share.appleId,
            iat: Date(),
            exp: Date(timeIntervalSinceNow: 3600),
            aud: AuthManager.share.aud,
            sub: AuthManager.share.claimsId
        )
        
        var jwt = JWT(header: header, claims: claims)
        
        let jwtSigner = JWTSigner.es256(privateKey: Data(AuthManager.share.digitalCertificate.utf8))
        
        do {
            let signedJWT = try jwt.sign(using: jwtSigner)
            guard let refreshToken = UserUid.share.keychain.get("refreshToken") else { return }
            
            let params = [
                "client_id": AuthManager.share.claimsId,
                "client_secret": signedJWT,
                "token": refreshToken,
                "token_type_hint": "refresh_token"
            ]
            
            AuthManager.share.removeAccount(params: params)
        } catch {
            print(error)
        }
    }
}
