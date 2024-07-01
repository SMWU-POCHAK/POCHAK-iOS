//
//  GoogleLoginModel.swift
//  pochak
//
//  Created by Seo Cindy on 12/27/23.
//

struct GoogleLoginResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: GoogleLoginModel
}

struct GoogleLoginModel : Codable {
    var socialId : String?
    var name : String?
    var email : String?
    var socialType : String?
    var accessToken : String?
    var refreshToken : String?
    var isNewMember : Bool?
}
