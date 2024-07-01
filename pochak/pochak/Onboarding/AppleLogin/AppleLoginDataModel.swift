//
//  AppleLoginDataModel.swift
//  pochak
//
//  Created by Seo Cindy on 7/1/24.
//

import Foundation

struct AppleLoginResponse: Codable {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: AppleLoginModel
}

struct AppleLoginModel : Codable {
    var socialId : String?
    var name : String?
    var email : String?
    var socialType : String?
    var accessToken : String?
    var refreshToken : String?
    var isNewMember : Bool?
}
