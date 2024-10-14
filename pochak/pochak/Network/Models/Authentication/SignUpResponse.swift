//
//  SignUpResponse.swift
//  pochak
//
//  Created by Seo Cindy on 10/1/24.
//

import Foundation

struct SignUpResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: SignUpResult
}

struct SignUpResult : Codable {
    var id : Int?
    var socialId : String?
    var name : String?
    var email : String?
    var socialType : String?
    var accessToken : String?
    var refreshToken : String?
    var isNewMember : Bool?
}
