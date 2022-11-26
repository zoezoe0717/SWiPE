//
//  AuthClaims.swift
//  SWiPE
//
//  Created by Zoe on 2022/11/24.
//

import SwiftJWT

struct AuthClaims: Claims {
    let iss: String
    
    let iat: Date
    
    let exp: Date
    
    let aud: String
    
    let sub: String
}
